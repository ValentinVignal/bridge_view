# Bridge View Implementation Plan

## Project Overview

Create a multi-device display extension system that allows 2 Android phones and an extra MacBook to extend (not mirror) the screen of a main MacBook. The devices act as "dumb screens" - they only display content without input capabilities.

**Core Technology Stack:**

- Server (Main Mac): Rust
- Client (Mobile & Desktop): Flutter (display-only)
- Protocol: Protocol Buffers
- Transport: WebSocket or QUIC over USB-C networking

---

## Phase 1: Foundation & Protocol (Day 1-2)

### Step 1.1: Protocol Definition

- [x] Create `protocol/proto/display.proto`
- [x] Define message types:
  - `ClientRegistration` (client info, device type, capabilities)
  - `DisplayConfig` (resolution, position, frame rate)
  - `VideoFrame` (encoded frame data, timestamp, sequence number)
  - `ControlMessage` (connection management, heartbeat)
- [x] Generate Rust code: `make rust`
- [x] Generate Dart code: `make dart`

### Step 1.2: Project Structure Setup

- [x] Initialize Rust project: `cargo init server`
- [x] Initialize Flutter project: `flutter create client`
- [x] Configure multi-platform support for Flutter (Android, macOS)
- [x] Add dependencies to `Cargo.toml` and `pubspec.yaml`
- [x] Create basic README files for each subproject

---

## Phase 2: Server - Basic Display Capture (Day 3-4)

### Step 2.1: Virtual Display Research & POC

- [x] Research macOS virtual display options:
  - CoreGraphics display configuration
  - Third-party drivers (e.g., BetterDisplay API)
  - CGConfigureDisplayMode for custom resolutions
- [x] Create proof-of-concept: detect connected displays
- [x] Document virtual display creation approach

### Step 2.2: Screen Capture Implementation

- [x] Implement capture module using `CGDisplayCreateImage` (simpler approach)
- [x] Capture entire virtual displays (not regions)
- [x] Convert captured frames to RGB/YUV format
- [x] Add frame rate limiting (30 fps initially)
- [x] Test capture performance and optimize

**Note**: Initial implementation uses `CGDisplayCreateImage` instead of `CGDisplayStream` due to complexity with blocks and dispatch queues. This successfully captures frames but needs optimization for continuous streaming.

### Step 2.3: Basic Encoding

- [x] Integrate H.264 encoder (ffmpeg or openh264)
- [x] Configure low-latency encoding settings
- [x] Implement frame queuing system
- [x] Add basic compression quality controls
- [x] Benchmark encoding performance

**Implementation Details:**

- Used `openh264` crate for H.264 encoding
- Created encoder module with quality presets (Low, Medium, High, Ultra)
- Implemented frame queuing with `crossbeam-channel` for thread-safe operation
- Added RGB to YUV420 (I420) color space conversion
- Created encoding queue that processes frames in background thread
- Added comprehensive benchmarking tests for encoding performance
- Quality presets automatically adjust bitrate based on resolution

---

## Phase 3: Server - Network Layer (Day 5)

### Step 3.1: Connection Manager

- [x] Implement WebSocket server using `tokio-tungstenite`
- [x] Add client connection handling
- [x] Implement client registration and handshake
- [x] Assign virtual displays to clients
- [x] Add connection state management

**Implementation Details:**

- Used `tokio-tungstenite` for async WebSocket server on `tokio` runtime
- Created `connection` module with `types`, `manager`, and `server` submodules
- `ConnectionManager` handles client registration, heartbeat tracking, and state management
- `WebSocketServer` listens on `0.0.0.0:9876`, accepts connections, and processes protobuf messages
- Client registration flow: client sends `ClientRegistration` protobuf → server validates → assigns session ID and `DisplayConfig` → sends config back
- Heartbeat monitoring with configurable interval and timeout (auto-disconnects stale clients)
- Supports up to 3 simultaneous clients, each assigned a unique display position
- Server mode launched with `cargo run -- --server`; legacy tests still available without flag
- Added dependencies: `tokio`, `tokio-tungstenite`, `futures-util`, `prost`, `uuid`, `log`, `env_logger`

### Step 3.2: Frame Streaming

- [x] Stream encoded frames to connected clients
- [x] Implement frame buffering and queue management
- [x] Add frame sequencing and timestamps
- [x] Handle client disconnection gracefully
- [x] Add basic error handling and logging

**Implementation Details:**

- Created `FrameStreamer` in `connection/streaming.rs` — orchestrates capture → encode → broadcast pipeline
- Runs on a background thread, capturing display frames at configurable FPS using `SimpleCapture`
- Feeds captured frames into the `EncodingQueue` for H.264 encoding in a separate worker thread
- Drains encoded frames and broadcasts them to all active clients as protobuf `VideoFrame` messages
- Per-client frame delivery via `tokio::sync::mpsc::UnboundedSender<Vec<u8>>` channels registered in `ConnectionManager`
- Each WebSocket connection spawns a dedicated frame-writer task that reads from the per-client channel and writes binary WebSocket messages
- `ConnectionManager::broadcast_frame()` converts `EncodedFrame` to protobuf `VideoFrame` with sequence numbers, timestamps, frame type (Keyframe/Delta), and resolution
- Automatic cleanup: failed sends trigger client disconnection and frame sender removal
- `StreamerHandle` provides `stop()` and `is_running()` for lifecycle management
- Periodic stats logging (every 5s): captured/encoded/broadcast/dropped frame counts and active client count
- `StreamingConfig` allows tuning target FPS, display ID, encoder quality, queue size, and drop-on-full behavior

### Step 3.3: Interactive Server CLI

Add an interactive REPL to the server so the operator can manage devices without leaving the terminal.

**Connection model per device type:**

| Device type         | What operator does                          | What client user does                         | Host in Flutter app               |
| ------------------- | ------------------------------------------- | --------------------------------------------- | --------------------------------- |
| Android phone (USB) | `assign` → runs `adb reverse` automatically | Opens app, taps Connect                       | `localhost`                       |
| Android emulator    | `assign` → runs `adb reverse` automatically | Opens app, taps Connect                       | `localhost`                       |
| macOS (Thunderbolt) | `assign` → prints the Thunderbolt IP        | Types that IP in the host field, taps Connect | Thunderbolt IP e.g. `169.254.x.x` |

> **Note:** macOS Thunderbolt uses a direct IP (not `localhost`) because the server already binds to
> `0.0.0.0:9876` which includes the `bridge100` interface — no tunnel is needed. SSH port forwarding
> was considered but rejected as unnecessary complexity for a direct physical cable connection.

**Commands:**

| Command             | Description                                                 |
| ------------------- | ----------------------------------------------------------- |
| `detect`            | Scan for connectable devices (ADB + Thunderbolt interfaces) |
| `assign <id>`       | Set up connection for a device from the `detect` list       |
| `status`            | Show currently connected clients and their state            |
| `kick <session_id>` | Forcefully disconnect a client                              |
| `help`              | List available commands                                     |
| `quit`              | Stop the server gracefully                                  |

**`detect` behaviour per device type:**

- **Android phone (USB)**: Parse `adb devices -l` output; show serial + model name (`adb -s SERIAL shell getprop ro.product.model`); exclude devices whose session is already active in `ConnectionManager`
- **Android emulator**: Same `adb devices` output; serial starts with `emulator-`; flag as emulator in the list
- **macOS via Thunderbolt/USB-C**: Enumerate network interfaces using the `if_addrs` crate; look for `bridge1xx` interfaces with APIPA addresses (`169.254.x.x`) which macOS auto-creates when two Macs are connected directly via Thunderbolt/USB-C cable

**`assign <id>` behaviour per device type:**

- **Android phone/emulator**:
  1. Run `adb -s <SERIAL> reverse tcp:9876 tcp:9876` on the Mac
  2. Print: `✓ Port forwarding set up. Open bridge_view on the device and connect to localhost:9876`
  3. The phone user does nothing special — `localhost` is the correct host
- **macOS Thunderbolt**:
  1. Print the Thunderbolt bridge IP (e.g. `169.254.x.x`) for the client Mac to use
  2. Print: `→ Open bridge_view on the Mac and connect to <thunderbolt-ip>:9876`
  3. The macOS client user enters that IP once in the host field

**Example session:**

```
> detect
Android (ADB):
  [1] emulator-5554    Pixel 7 API 34         (emulator)
  [2] R3CN10XXXXX      Samsung Galaxy S23     (not connected)
Thunderbolt/USB-C:
  [3] bridge100        169.254.100.2          (direct Mac-to-Mac)
Already connected: (none)

> assign 2
✓ adb reverse tcp:9876 tcp:9876  [R3CN10XXXXX]
→ Open bridge_view on the phone and connect to localhost:9876

> assign 3
→ Open bridge_view on the Mac and connect to 169.254.100.2:9876

> status
[session-abc]  flutter-android-...  Samsung Galaxy S23  Active
[session-def]  flutter-macos-...    MacBook Pro         Registering
```

**Implementation notes:**

- Read stdin in a background `tokio::spawn` task using `tokio::io::BufReader` over `tokio::io::stdin()`
- Use `tokio::process::Command` (non-blocking) to invoke `adb` subcommands
- Add `if_addrs` crate for network interface enumeration
- Optionally add `rustyline` crate for readline history/tab-completion
- `adb` must be installed and on `PATH` on the server Mac (part of Android SDK platform-tools)

**Implemented:**

- Created `connection/cli.rs` with `run_cli(manager, shutdown_tx)` async function
- `detect` enumerates ADB devices (serial + model via `ro.product.model`) and Thunderbolt bridge interfaces (169.254.x.x APIPA addresses on `bridge*` interfaces)
- `assign <id>` runs `adb -s <SERIAL> reverse tcp:9876 tcp:9876` for Android or prints the Thunderbolt IP for macOS
- `status` calls `ConnectionManager::client_summary()`; `kick <session_id>` calls `ConnectionManager::disconnect_client()`
- CLI spawned as a `tokio::spawn` task; `quit` sends on a `oneshot` channel; `main.rs` uses `tokio::select!` to stop the server when the signal arrives
- Added `if-addrs = "0.13"` to `Cargo.toml`

---

## Phase 4: Client - Basic Rendering (Day 6-7)

### Step 4.1: Connection & Protocol

- [x] Implement WebSocket client in Flutter
- [x] Parse protobuf messages
- [x] Implement client registration flow
- [x] Add connection status UI
- [x] Handle reconnection logic

### Step 4.2: Video Decoding & Rendering

- [x] Integrate video player plugin
- [x] Decode H.264 stream
- [x] Render frames fullscreen
- [x] Optimize rendering performance
- [x] Add frame rate monitoring

**Implementation Details:**

- Used platform channels (`bridge_view/h264_renderer` MethodChannel) instead of a video player plugin for lower latency and direct hardware access
- Android: `H264RendererPlugin` using `MediaCodec` (Annex-B → Surface); lazily initialised on first keyframe after extracting SPS/PPS as CSD
- macOS: `H264RendererPlugin` using `VideoToolbox` (`VTDecompressionSession`); converts Annex-B to AVCC and outputs `kCVPixelFormatType_32BGRA` pixel buffers via Flutter `Texture`
- `H264Renderer` Dart class wraps the method channel; `decodeFrame()` is fire-and-forget (no await) to keep the frame pipeline unblocked
- `VideoDisplayWidget` subscribes to `BridgeViewClient.frameStream`, dispatches each frame to the native decoder, and renders via `Texture(textureId: ...)`
- `DisplayScreen` takes over full-screen via `SystemUiMode.immersiveSticky`; navigated to automatically when `ConnectionStatus.connected`; pops back on disconnect
- FPS monitoring: 1-second rolling window counter shown as an overlay in `VideoDisplayWidget`

### Step 4.3: Platform-Specific Setup

- [x] Configure Android fullscreen mode
- [x] Configure macOS fullscreen window
- [x] Handle device rotation (Android)
- [x] Disable sleep/screen timeout
- [x] Add wake lock functionality

**Implementation Details:**

- `DisplayScreen` already hid system UI via `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`; added `android:windowLayoutInDisplayCutoutMode="shortEdges"` to both `styles.xml` variants so fullscreen video also extends under notches/cutouts
- Added `wakelock_plus`: `WakelockPlus.enable()` on entering `DisplayScreen`, `WakelockPlus.disable()` on dispose, keeping the screen awake only while actively displaying
- Android rotation: `DisplayScreen` locks `SystemChrome.setPreferredOrientations(...)` to landscape or portrait based on the assigned `DisplayConfig` aspect ratio once the config arrives, and resets to unrestricted on dispose
- macOS fullscreen window: added a new Pigeon `HostApi` (`WindowControlApi`) with `enterFullScreen()`/`exitFullScreen()`, implemented in `WindowControlPlugin.swift` by toggling `NSWindow.toggleFullScreen`; `DisplayScreen` calls it (guarded by `defaultTargetPlatform == TargetPlatform.macOS`) on enter/exit
- Merged the `H264RendererApi` and `WindowControlApi` Pigeon definitions into a single `pigeons/native_apis.dart` → `lib/platform/native_apis.g.dart` / `macos/Runner/NativeApis.g.swift` / Kotlin output, since separate Pigeon-generated Swift files sharing a compile target collide on top-level helper declarations (`PigeonError`, etc.)
- Fixed a pre-existing gap where native macOS Swift files (H264 renderer plugin and its Pigeon output) were never added to `Runner.xcodeproj`'s build phase, so `flutter build macos` was silently not compiling them; wired all native Swift sources into the Xcode project

---

## Phase 5: Virtual Display Management (Day 8-10)

### Step 5.1: Display Configuration

- [x] Create virtual displays programmatically
- [x] Configure display positions (extend right/left)
- [x] Set custom resolutions based on client devices
- [x] Implement display arrangement UI/config
- [x] Handle dynamic client connections

**Implementation Details:**

- Per `doc/virtual-display-research.md`, true virtual display creation isn't feasible for the MVP (requires a DriverKit driver); instead each client is assigned one of the Mac's currently _active_ displays (its own physical monitors, or dummy HDMI/USB-C plugs), and macOS's own arrangement (System Settings → Displays) determines left/right extension — the server just reads each display's real geometry
- `ConnectionManager::pick_available_display()` picks a `CGDirectDisplayID` not already assigned to another connected client (falling back to the main display when no spare display is connected, e.g. local dev with a single Mac)
- `ClientConnection::assigned_display_id` stores the picked display; freed automatically when the client is removed on disconnect/timeout
- `ClientConnection::create_display_config()` now builds `DisplayConfig`/`DisplayPosition` from the assigned display's _real_ `CGDisplay::bounds()`, capped to the client's reported `max_width`/`max_height`/`max_framerate` capabilities (previously this was a synthetic index-based offset)
- Replaced the single global `FrameStreamer` (which captured one display and broadcast identical frames to every client) with a new `StreamerPool` that subscribes to the manager's `registered:`/`disconnected:`/`timeout:` events and spins up one dedicated `FrameStreamer` per client, each capturing only that client's assigned display and sending frames only to that client (`ConnectionManager::send_frame`, replacing `broadcast_frame`)
- Added a `displays` CLI command to list active macOS displays (id, resolution, position, main/extended) for arrangement visibility/debugging; `status` now also shows each client's assigned display id

### Step 5.2: Multi-Client Support

- [x] Support 3 simultaneous clients
- [x] Assign unique display regions to each client
- [x] Handle client priority and ordering
- [x] Implement display re-arrangement
- [ ] Test with all devices connected

**Implementation Details:**

- `ServerConfig::max_clients` defaults to 3 and is enforced in `ConnectionManager::register_client()`; `StreamerPool` already spins up one dedicated `FrameStreamer` per connected client (from Step 5.1), so 3 clients each get their own capture/encode/send pipeline running concurrently
- **Client priority and ordering**: added `sticky_assignments: HashMap<client_id, CGDirectDisplayID>` to `ConnectionManager`, keyed by the client's stable self-reported `client_id` (not the ephemeral `session_id`). `pick_available_display()` now prefers a client's previous display if it's still active and unclaimed, so reconnecting devices keep the same extended-display slot instead of being reshuffled to whatever's free. Updated on both initial registration and manual `set-display` reassignment
- **Display re-arrangement**: `set-display <session_id> <display_id>` (added previously) reassigns one client to a free display. Added a new `swap-displays <session_id_a> <session_id_b>` CLI command + `ConnectionManager::swap_displays()` to atomically exchange displays between two already-connected clients — `reassign_display` alone can't do this since both target displays are already "taken" from each other's perspective
- Remaining item is manual: physically connecting 2 phones + 1 macOS client simultaneously and verifying independent streams

---

## Phase 6: Optimization & Polish (Day 11-12)

### Step 6.1: Performance Optimization

- [ ] Optimize encoding settings for low latency
- [ ] Implement adaptive bitrate based on connection
- [ ] Reduce frame processing overhead
- [ ] Optimize memory usage
- [ ] Profile and fix bottlenecks

### Step 6.2: User Experience

- [ ] Add client UI for connection status
- [ ] Add server UI/tray icon for management
- [ ] Implement configuration persistence
- [ ] Add error messages and recovery
- [ ] Create connection setup wizard

### Step 6.3: Testing & Documentation

- [ ] Test all connection scenarios
- [ ] Test with all device combinations
- [ ] Document setup instructions
- [ ] Document USB-C connection process
- [ ] Create troubleshooting guide

---

## Phase 7: Advanced Features (Day 13+)

### Step 7.1: Enhanced Features

- [ ] Audio streaming to clients (optional)
- [ ] Clipboard synchronization
- [ ] Display settings (brightness, orientation)
- [ ] Multiple encoding quality presets
- [ ] Wireless fallback (WiFi)
- [ ] Cursor rendering: `CGDisplayCreateImage` (used by `SimpleCapture`) does not
      include the mouse cursor in captured frames, so it's currently invisible
      on clients. Either switch capture to `ScreenCaptureKit`
      (`SCStreamConfiguration.showsCursor`) or track cursor position/image
      separately on the server and composite it client-side.

### Step 7.2: Production Readiness

- [ ] Add comprehensive error handling
- [ ] Implement logging and diagnostics
- [ ] Create installer/package for server
- [ ] Build APK for Android
- [ ] Build macOS app bundle for client
- [ ] Add auto-update mechanism

---

## Immediate Next Steps (Start Here)

1. **Day 1 Morning**: Set up protocol definitions
2. **Day 1 Afternoon**: Initialize projects and dependencies
3. **Day 2**: Implement basic screen capture POC
4. **Day 3**: Get first frame streaming to client

## Success Criteria

- ✅ 3 devices can connect simultaneously via USB-C
- ✅ Each device displays unique extended screen content
- ✅ Frame rate is smooth (≥30fps)
- ✅ Latency is acceptable (<100ms)
- ✅ Setup is repeatable and documented

## Risk Mitigation

**Risk**: macOS virtual display creation is complex

- **Mitigation**: Start with manual display configuration, automate later

**Risk**: Encoding/decoding latency too high

- **Mitigation**: Use hardware encoding (VideoToolbox), optimize settings

**Risk**: USB-C networking unstable

- **Mitigation**: Implement WiFi fallback, add robust reconnection logic
