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

### Step 3.3: USB-C Network Configuration

- [ ] Document USB networking setup for macOS
- [ ] Test connectivity with Android over USB-C
- [ ] Test connectivity with macOS over USB-C
- [ ] Configure static IPs or mDNS discovery

---

## Phase 4: Client - Basic Rendering (Day 6-7)

### Step 4.1: Connection & Protocol

- [ ] Implement WebSocket client in Flutter
- [ ] Parse protobuf messages
- [ ] Implement client registration flow
- [ ] Add connection status UI
- [ ] Handle reconnection logic

### Step 4.2: Video Decoding & Rendering

- [ ] Integrate video player plugin
- [ ] Decode H.264 stream
- [ ] Render frames fullscreen
- [ ] Optimize rendering performance
- [ ] Add frame rate monitoring

### Step 4.3: Platform-Specific Setup

- [ ] Configure Android fullscreen mode
- [ ] Configure macOS fullscreen window
- [ ] Handle device rotation (Android)
- [ ] Disable sleep/screen timeout
- [ ] Add wake lock functionality

---

## Phase 5: Virtual Display Management (Day 8-10)

### Step 5.1: Display Configuration

- [ ] Create virtual displays programmatically
- [ ] Configure display positions (extend right/left)
- [ ] Set custom resolutions based on client devices
- [ ] Implement display arrangement UI/config
- [ ] Handle dynamic client connections

### Step 5.2: Multi-Client Support

- [ ] Support 3 simultaneous clients
- [ ] Assign unique display regions to each client
- [ ] Handle client priority and ordering
- [ ] Implement display re-arrangement
- [ ] Test with all devices connected

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
