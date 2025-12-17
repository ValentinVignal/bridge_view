use core_graphics::display::CGDisplay;

fn main() {
    println!("Bridge View Server - Display Detection POC\n");

    // Detect all connected displays
    detect_displays();
}

fn detect_displays() {
    // Get the main display
    let main_display = CGDisplay::main();
    println!("Main Display:");
    print_display_info(&main_display, true);

    // Get all active displays
    match CGDisplay::active_displays() {
        Ok(displays) => {
            println!("\nTotal Active Displays: {}\n", displays.len());

            for (index, display_id) in displays.iter().enumerate() {
                let display = CGDisplay::new(*display_id);
                let is_main = display.id == main_display.id;
                println!("Display #{} (ID: {}):", index + 1, display_id);
                print_display_info(&display, is_main);
                println!();
            }
        }
        Err(e) => {
            eprintln!("Error getting active displays: {:?}", e);
        }
    }
}

fn print_display_info(display: &CGDisplay, is_main: bool) {
    let bounds = display.bounds();
    let mode = display.display_mode();

    println!("  Type: {}", if is_main { "Main" } else { "Extended" });
    println!("  ID: {}", display.id);
    println!("  Position: ({}, {})", bounds.origin.x, bounds.origin.y);
    println!("  Size: {}x{}", bounds.size.width, bounds.size.height);

    if let Some(mode) = mode {
        println!("  Resolution: {}x{}", mode.width(), mode.height());
        println!("  Refresh Rate: {} Hz", mode.refresh_rate());
        println!("  Pixel Encoding: {}", mode.pixel_encoding());
    }

    println!("  Built-in: {}", display.is_builtin());
    println!("  Active: {}", display.is_active());
    println!("  Online: {}", display.is_online());
    println!(
        "  Hardware Accelerated: {}",
        display.uses_open_gl_acceleration()
    );
}
