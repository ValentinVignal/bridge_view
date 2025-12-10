# Bridge View Implementation Plan

## Project Overview

Create a multi-device display extension system that allows 2 Android phones and an extra MacBook to extend (not mirror) the screen of a main MacBook.

**Core Technology Stack:**

- Server (Main Mac): Rust
- Client (Mobile & Desktop): Flutter
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
  - `InputEvent` (mouse, keyboard, touch events with coordinates)
  - `ControlMessage` (connection management, heartbeat)
- [x] Generate Rust code: `make rust`
- [ ] Generate Dart code: `protoc --dart_out=client/lib/proto`

### Step 1.2: Project Structure Setup

- [ ] Initialize Rust project: `cargo init server`
- [ ] Initialize Flutter project: `flutter create client`
- [ ] Configure multi-platform support for Flutter (Android, macOS)
- [ ] Add dependencies to `Cargo.toml` and `pubspec.yaml`
- [ ] Create basic README files for each subproject

---

## Phase 2: Server - Basic Display Capture (Day 3-4)

### Step 2.1: Virtual Display Research & POC

- [ ] Research macOS virtual display options:
  - CoreGraphics display configuration
  - Third-party drivers (e.g., BetterDisplay API)
  - CGConfigureDisplayMode for custom resolutions
- [ ] Create proof-of-concept: detect connected displays
- [ ] Document virtual display creation approach

### Step 2.2: Screen Capture Implementation

- [ ] Implement capture module using `CGDisplayStream`
- [ ] Capture specific screen regions (virtual display areas)
- [ ] Convert captured frames to RGB/YUV format
- [ ] Add frame rate limiting (30 fps initially)
- [ ] Test capture performance and optimize

### Step 2.3: Basic Encoding

- [ ] Integrate H.264 encoder (ffmpeg or openh264)
- [ ] Configure low-latency encoding settings
- [ ] Implement frame queuing system
- [ ] Add basic compression quality controls
- [ ] Benchmark encoding performance

---

## Phase 3: Server - Network Layer (Day 5)

### Step 3.1: Connection Manager

- [ ] Implement WebSocket server using `tokio-tungstenite`
- [ ] Add client connection handling
- [ ] Implement client registration and handshake
- [ ] Assign display regions to clients
- [ ] Add connection state management

### Step 3.2: Frame Streaming

- [ ] Stream encoded frames to connected clients
- [ ] Implement frame buffering and queue management
- [ ] Add frame sequencing and timestamps
- [ ] Handle client disconnection gracefully
- [ ] Add basic error handling and logging

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

## Phase 5: Input Handling (Day 8-9)

### Step 5.1: Client Input Capture

- [ ] Capture touch events (Android)
- [ ] Capture mouse/trackpad events (macOS client)
- [ ] Capture keyboard events
- [ ] Transform coordinates to server display space
- [ ] Send input events to server

### Step 5.2: Server Input Injection

- [ ] Receive input events from clients
- [ ] Transform coordinates to virtual display space
- [ ] Inject mouse events using CGEvent APIs
- [ ] Inject keyboard events
- [ ] Test input accuracy and latency

---

## Phase 6: Virtual Display Management (Day 10-12)

### Step 6.1: Display Configuration

- [ ] Create virtual displays programmatically
- [ ] Configure display positions (extend right/left)
- [ ] Set custom resolutions based on client devices
- [ ] Implement display arrangement UI/config
- [ ] Handle dynamic client connections

### Step 6.2: Multi-Client Support

- [ ] Support 3 simultaneous clients
- [ ] Assign unique display regions to each client
- [ ] Handle client priority and ordering
- [ ] Implement display re-arrangement
- [ ] Test with all devices connected

---

## Phase 7: Optimization & Polish (Day 13-14)

### Step 7.1: Performance Optimization

- [ ] Optimize encoding settings for low latency
- [ ] Implement adaptive bitrate based on connection
- [ ] Reduce frame processing overhead
- [ ] Optimize memory usage
- [ ] Profile and fix bottlenecks

### Step 7.2: User Experience

- [ ] Add client UI for connection status
- [ ] Add server UI/tray icon for management
- [ ] Implement configuration persistence
- [ ] Add error messages and recovery
- [ ] Create connection setup wizard

### Step 7.3: Testing & Documentation

- [ ] Test all connection scenarios
- [ ] Test with all device combinations
- [ ] Document setup instructions
- [ ] Document USB-C connection process
- [ ] Create troubleshooting guide

---

## Phase 8: Advanced Features (Day 15+)

### Step 8.1: Enhanced Features

- [ ] Audio streaming to clients (optional)
- [ ] Clipboard synchronization
- [ ] Display settings (brightness, orientation)
- [ ] Multiple encoding quality presets
- [ ] Wireless fallback (WiFi)

### Step 8.2: Production Readiness

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
- ✅ Each device displays unique extended screen region
- ✅ Input events work with acceptable latency (<100ms)
- ✅ Frame rate is smooth (≥30fps)
- ✅ Setup is repeatable and documented

## Risk Mitigation

**Risk**: macOS virtual display creation is complex

- **Mitigation**: Start with manual display configuration, automate later

**Risk**: Encoding/decoding latency too high

- **Mitigation**: Use hardware encoding (VideoToolbox), optimize settings

**Risk**: USB-C networking unstable

- **Mitigation**: Implement WiFi fallback, add robust reconnection logic

**Risk**: Input coordinate transformation errors

- **Mitigation**: Build calibration tool, add visual debugging
