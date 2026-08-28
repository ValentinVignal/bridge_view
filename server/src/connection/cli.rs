use std::io::Write;
use std::sync::Arc;

use core_graphics::display::CGDisplay;
use log::info;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::sync::oneshot;

use super::manager::ConnectionManager;

/// A device discovered by the `detect` command.
enum DetectedDevice {
    Android {
        serial: String,
        model: String,
        is_emulator: bool,
    },
    Thunderbolt {
        interface: String,
        ip: String,
    },
}

/// Run the interactive CLI on the current task.
///
/// Reads lines from stdin and dispatches commands. Signals `shutdown_tx` when
/// the operator types `quit` or EOF is received.
pub async fn run_cli(manager: Arc<ConnectionManager>, shutdown_tx: oneshot::Sender<()>) {
    println!("Bridge View Server CLI — type `help` for available commands.");
    prompt();

    let stdin = tokio::io::stdin();
    let mut lines = BufReader::new(stdin).lines();
    let mut detected: Vec<DetectedDevice> = Vec::new();
    let mut shutdown_tx = Some(shutdown_tx);

    loop {
        match lines.next_line().await {
            Ok(Some(line)) => {
                let line = line.trim().to_string();
                let mut parts = line.splitn(2, ' ');
                let cmd = parts.next().unwrap_or("").trim();
                let arg = parts.next().map(|s| s.trim());

                match cmd {
                    "detect" | "d" => {
                        detected = do_detect().await;
                    }
                    "assign" => match arg.and_then(|a| a.parse::<usize>().ok()) {
                        Some(id) if id >= 1 && id <= detected.len() => {
                            do_assign(&detected[id - 1]).await;
                        }
                        _ => {
                            if detected.is_empty() {
                                println!("No devices detected yet. Run `detect` first.");
                            } else {
                                println!("Usage: assign <id>  (1–{})", detected.len());
                            }
                        }
                    },
                    "status" | "s" => {
                        do_status(&manager).await;
                    }
                    "displays" => {
                        do_displays();
                    }
                    "set-display" => match parse_set_display_args(arg) {
                        Some((session_id, display_id)) => {
                            do_set_display(&manager, &session_id, display_id).await;
                        }
                        None => {
                            println!("Usage: set-display <session_id> <display_id>");
                        }
                    },
                    "kick" => match arg {
                        Some(session_id) => {
                            match manager
                                .disconnect_client(session_id, "Kicked by operator")
                                .await
                            {
                                Ok(()) => println!("✓ Kicked session {}", session_id),
                                Err(e) => println!("Error: {}", e),
                            }
                        }
                        None => println!("Usage: kick <session_id>"),
                    },
                    "help" | "h" => print_help(),
                    "quit" | "q" => {
                        println!("Shutting down server…");
                        if let Some(tx) = shutdown_tx.take() {
                            let _ = tx.send(());
                        }
                        break;
                    }
                    "" => {}
                    other => println!(
                        "Unknown command: '{}'. Type `help` or `h` for available commands.",
                        other
                    ),
                }

                if shutdown_tx.is_some() {
                    prompt();
                }
            }
            Ok(None) => {
                // EOF — stdin closed (e.g. piped input or terminal close)
                info!("CLI stdin closed, signalling shutdown");
                if let Some(tx) = shutdown_tx.take() {
                    let _ = tx.send(());
                }
                break;
            }
            Err(e) => {
                eprintln!("CLI read error: {}", e);
                break;
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Command implementations
// ---------------------------------------------------------------------------

async fn do_detect() -> Vec<DetectedDevice> {
    let mut devices: Vec<DetectedDevice> = Vec::new();

    // --- ADB / Android devices -----------------------------------------------
    println!("Android (ADB):");
    match detect_adb_devices().await {
        Ok(adb_devs) if !adb_devs.is_empty() => {
            let start = devices.len();
            devices.extend(adb_devs);
            for (i, dev) in devices[start..].iter().enumerate() {
                if let DetectedDevice::Android {
                    serial,
                    model,
                    is_emulator,
                } = dev
                {
                    let tag = if *is_emulator { "(emulator)" } else { "" };
                    println!(
                        "  [{:>2}] {:<22} {:<30} {}",
                        start + i + 1,
                        serial,
                        model,
                        tag
                    );
                }
            }
        }
        Ok(_) => println!("  (none)"),
        Err(e) => println!("  adb error: {}", e),
    }

    // --- Thunderbolt / USB-C direct Mac-to-Mac --------------------------------
    println!("Thunderbolt/USB-C:");
    match detect_thunderbolt_interfaces() {
        Ok(tb_devs) if !tb_devs.is_empty() => {
            let start = devices.len();
            devices.extend(tb_devs);
            for (i, dev) in devices[start..].iter().enumerate() {
                if let DetectedDevice::Thunderbolt { interface, ip } = dev {
                    println!(
                        "  [{:>2}] {:<22} {} (direct Mac-to-Mac)",
                        start + i + 1,
                        interface,
                        ip
                    );
                }
            }
        }
        Ok(_) => println!("  (none)"),
        Err(e) => println!("  interface error: {}", e),
    }

    if devices.is_empty() {
        println!("No devices found.");
    }

    devices
}

async fn detect_adb_devices() -> Result<Vec<DetectedDevice>, String> {
    let output = tokio::process::Command::new("adb")
        .args(["devices", "-l"])
        .output()
        .await
        .map_err(|e| format!("adb not found or not on PATH: {}", e))?;

    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut devices = Vec::new();

    for line in stdout.lines().skip(1) {
        // skip "List of devices attached"
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let parts: Vec<&str> = line.split_whitespace().collect();
        if parts.len() < 2 {
            continue;
        }

        let serial = parts[0].to_string();
        let state = parts[1];

        // Only include devices that are actually connected and authorised
        if state != "device" {
            continue;
        }

        let is_emulator = serial.starts_with("emulator-");
        let model = adb_get_model(&serial)
            .await
            .unwrap_or_else(|_| "Unknown".to_string());

        devices.push(DetectedDevice::Android {
            serial,
            model,
            is_emulator,
        });
    }

    Ok(devices)
}

async fn adb_get_model(serial: &str) -> Result<String, String> {
    let output = tokio::process::Command::new("adb")
        .args(["-s", serial, "shell", "getprop", "ro.product.model"])
        .output()
        .await
        .map_err(|e| e.to_string())?;

    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
    } else {
        Err(String::from_utf8_lossy(&output.stderr).to_string())
    }
}

fn detect_thunderbolt_interfaces() -> Result<Vec<DetectedDevice>, String> {
    let addrs = if_addrs::get_if_addrs().map_err(|e| e.to_string())?;
    let mut devices = Vec::new();

    for iface in addrs {
        // macOS names Thunderbolt bridge interfaces "bridge0", "bridge100", etc.
        if !iface.name.starts_with("bridge") {
            continue;
        }

        if let if_addrs::IfAddr::V4(ref v4) = iface.addr {
            let octets = v4.ip.octets();
            // APIPA range: 169.254.0.0/16 — macOS auto-assigns these for
            // direct Thunderbolt / USB-C connections between two Macs.
            if octets[0] == 169 && octets[1] == 254 {
                devices.push(DetectedDevice::Thunderbolt {
                    interface: iface.name.clone(),
                    ip: v4.ip.to_string(),
                });
            }
        }
    }

    Ok(devices)
}

async fn do_assign(device: &DetectedDevice) {
    match device {
        DetectedDevice::Android { serial, .. } => {
            println!("Setting up port forwarding for {}…", serial);
            match tokio::process::Command::new("adb")
                .args(["-s", serial, "reverse", "tcp:9876", "tcp:9876"])
                .output()
                .await
            {
                Ok(output) if output.status.success() => {
                    println!("✓ adb reverse tcp:9876 tcp:9876  [{}]", serial);
                    println!("→ Open bridge_view on the device and connect to localhost:9876");
                }
                Ok(output) => {
                    eprintln!("adb error: {}", String::from_utf8_lossy(&output.stderr));
                }
                Err(e) => {
                    eprintln!("Failed to run adb: {}", e);
                }
            }
        }
        DetectedDevice::Thunderbolt { ip, .. } => {
            println!("→ Open bridge_view on the Mac and connect to {}:9876", ip);
        }
    }
}

async fn do_status(manager: &ConnectionManager) {
    let summary = manager.client_summary().await;
    if summary.is_empty() {
        println!("No clients connected.");
    } else {
        for (session_id, desc, state, display_id) in &summary {
            println!(
                "[{}]  {}  {}  display={}",
                session_id, desc, state, display_id
            );
        }
    }
}

/// Parse `"<session_id> <display_id>"` from the `set-display` argument string.
fn parse_set_display_args(arg: Option<&str>) -> Option<(String, u32)> {
    let arg = arg?;
    let mut parts = arg.splitn(2, ' ');
    let session_id = parts.next()?.trim().to_string();
    let display_id: u32 = parts.next()?.trim().parse().ok()?;
    if session_id.is_empty() {
        return None;
    }
    Some((session_id, display_id))
}

async fn do_set_display(manager: &Arc<ConnectionManager>, session_id: &str, display_id: u32) {
    match manager.reassign_display(session_id, display_id).await {
        Ok(config) => {
            manager.push_display_config(session_id, &config).await;
            manager.notify_display_changed(session_id);
            println!(
                "✓ Session {} reassigned to display {}",
                session_id, display_id
            );
        }
        Err(e) => println!("Error: {}", e),
    }
}

fn do_displays() {
    let main_id = CGDisplay::main().id;
    match CGDisplay::active_displays() {
        Ok(displays) => {
            println!("Active displays ({}):", displays.len());
            for id in displays {
                let display = CGDisplay::new(id);
                let bounds = display.bounds();
                let tag = if id == main_id { "main" } else { "extended" };
                println!(
                    "  [{}] {}x{} at ({}, {})  ({})",
                    id,
                    bounds.size.width as u32,
                    bounds.size.height as u32,
                    bounds.origin.x as i32,
                    bounds.origin.y as i32,
                    tag
                );
            }
        }
        Err(e) => println!("Error listing displays: {:?}", e),
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn print_help() {
    println!("Commands:");
    println!("  detect              Scan for connectable devices (ADB + Thunderbolt)");
    println!("  assign <id>         Set up connection for a device from the detect list");
    println!("  status              Show currently connected clients and their state");
    println!("  displays            List active macOS displays available for capture");
    println!("  set-display <session_id> <display_id>");
    println!("                      Reassign a connected client to a different display");
    println!("  kick <session_id>   Forcefully disconnect a client");
    println!("  help                Show this help message");
    println!("  quit                Stop the server gracefully");
}

fn prompt() {
    print!("> ");
    let _ = std::io::stdout().flush();
}
