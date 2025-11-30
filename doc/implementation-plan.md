# Multi-Monitor App Implementation Plan

## Overview

Build a screen-sharing solution that turns extra macOS and Android devices into external monitors.

---

## Phase 1: Setup & Protocol (Week 1)

### Start Here: Protocol Project

**Why start with protocol?**

- Defines the contract between server and client
- Allows parallel development later
- Ensures type safety from the beginning

### Steps:

#### 1.1 Initialize Protocol Crate

```bash
cargo new --lib protocol
cd protocol
```

#### 1.2 Add Dependencies

```toml
# protocol/Cargo.toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
bincode = "1.3"  # For binary serialization
```

#### 1.3 Define Core Protocol Messages

Create basic message types:

- Connection handshake
- Display metadata (resolution, position)
- Frame data structure
- Control messages (disconnect, resize)

**Test:** Write unit tests for serialization/deserialization

#### Resources:

- [Serde Documentation](https://serde.rs/)
- [Rust Book - Testing](https://doc.rust-lang.org/book/ch11-00-testing.html)

---

## Phase 2: Server - Screen Capture (Week 2-3)

### Start: Server Project

#### 2.1 Initialize Server

```bash
cargo new server
cd server
```

#### 2.2 Add Dependencies

```toml
# server/Cargo.toml
[dependencies]
protocol = { path = "../protocol" }
tokio = { version = "1", features = ["full"] }
serde_json = "1.0"

# Screen capture (macOS)
screencapturekit = "0.2"  # macOS native
# OR
scrap = "0.5"  # Cross-platform alternative

# Optional: for testing
image = "0.24"
```

#### 2.3 Implement Screen Capture Module

**Big Step 1:** Capture a single screenshot and save to file

```rust
// Test: cargo run should save screenshot.png
fn capture_screen() -> Result<Vec<u8>, Error> {
    // Implement screen capture
}
```

**Big Step 2:** Continuous screen capture at 30 FPS

**Test:** Print FPS to console, verify smooth capture

#### Resources:

- [ScreenCaptureKit (macOS)](https://developer.apple.com/documentation/screencapturekit)
- [scrap crate](https://docs.rs/scrap/latest/scrap/)
- [Tokio Tutorial](https://tokio.rs/tokio/tutorial)

---

## Phase 3: Server - Network/USB Transport (Week 4)

### Choose Transport Method

#### Option A: Network (Easier to Start)

```toml
# server/Cargo.toml
[dependencies]
tokio = { version = "1", features = ["net"] }
```

**Big Step 3:** Create TCP server that broadcasts screen data

```bash
# Test: Use netcat to receive data
nc localhost 8080
```

#### Option B: USB (Better Performance)

```toml
# server/Cargo.toml
[dependencies]
rusb = "0.9"  # For USB communication
```

**Big Step 3:** Detect connected USB devices

**Test:** Print connected device list

#### Resources:

- [Tokio TCP Example](https://tokio.rs/tokio/tutorial/io)
- [rusb Documentation](https://docs.rs/rusb/latest/rusb/)
- [libimobiledevice](https://libimobiledevice.org/) (for iOS/macOS USB)

---

## Phase 4: Server - Complete Integration (Week 5)

**Big Step 4:** Combine capture + transport

Create a server that:

1. Captures screen at 30 FPS
2. Encodes frames (JPEG/H.264)
3. Sends to connected clients

```toml
# Add encoding
[dependencies]
mozjpeg = "0.10"  # Fast JPEG encoding
# OR
ffmpeg-next = "6.0"  # For H.264
```

**Test:** Stream to VLC player via network

```bash
# VLC can receive raw TCP streams
vlc tcp://localhost:8080
```

#### Resources:

- [mozjpeg crate](https://docs.rs/mozjpeg/latest/mozjpeg/)
- [Video Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/H.264)

---

## Phase 5: Flutter Client - Basic Display (Week 6-7)

### Initialize Flutter Project

```bash
flutter create client
cd client
```

#### 5.1 Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # For network
  web_socket_channel: ^2.4.0

  # For image display
  cached_network_image: ^3.3.0

  # Optional: Rust bridge
  flutter_rust_bridge: ^2.0.0
```

#### 5.2 Big Step 5: Display Static Image from Server

Create a simple Flutter app that:

1. Connects to server
2. Receives one frame
3. Displays it fullscreen

**Test:** See your Mac screen on the Flutter app

#### 5.3 Big Step 6: Continuous Streaming

Implement:

- Receive frames continuously
- Display with minimal latency
- Handle reconnection

**Test:** Move windows on main Mac, see updates on client

#### Resources:

- [Flutter Networking](https://docs.flutter.dev/cookbook/networking/web-sockets)
- [Flutter Rust Bridge](https://cjycode.com/flutter_rust_bridge/)
- [Image Display Tutorial](https://docs.flutter.dev/cookbook/images/network-images)

---

## Phase 6: Platform-Specific Builds (Week 8)

### 6.1 Android Build

```bash
flutter build apk
# Test on physical device via USB
flutter install
```

**Big Step 7:** Install and run on Android phone

#### 6.2 macOS Build

```bash
flutter build macos
open build/macos/Build/Products/Release/client.app
```

**Big Step 8:** Run on second macOS machine

#### Resources:

- [Flutter Platform Setup](https://docs.flutter.dev/get-started/install)
- [Android Debug Bridge](https://developer.android.com/studio/command-line/adb)

---

## Phase 7: USB Connection (Week 9-10)

### If choosing USB over network:

#### 7.1 Server Side

```toml
[dependencies]
rusb = "0.9"
usbmuxd = "0.2"  # For iOS/Android via USB
```

**Big Step 9:** Establish USB communication channel

#### 7.2 Client Side (Flutter)

```yaml
dependencies:
  usb_serial: ^0.5.0 # Android
  # For iOS, use platform channels with libimobiledevice
```

**Test:** Send/receive test data via USB

#### Resources:

- [usbmuxd](https://github.com/libimobiledevice/usbmuxd)
- [Android USB Host](https://developer.android.com/guide/topics/connectivity/usb/host)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)

---

## Phase 8: Optimization & Features (Week 11+)

### Performance Optimization

**Big Step 10:** Optimize encoding/decoding

- Experiment with H.264 vs JPEG
- Implement frame skipping
- Add quality settings

**Test:** Measure latency and FPS

### Additional Features

- [ ] Multi-monitor support (extend vs mirror)
- [ ] Touch input from phone → main Mac
- [ ] Resolution/quality settings
- [ ] Auto-discovery of devices
- [ ] Encryption for network mode

#### Resources:

- [Video Compression Guide](https://trac.ffmpeg.org/wiki/Encode/H.264)
- [WebRTC for low latency](https://webrtc.org/)

---

## Recommended Package Summary

### Protocol

- `serde` + `serde_json` - Serialization
- `bincode` - Binary format (optional)

### Server (Rust)

- `tokio` - Async runtime
- `screencapturekit` / `scrap` - Screen capture
- `mozjpeg` / `ffmpeg-next` - Encoding
- `tokio::net` - TCP (network mode)
- `rusb` + `usbmuxd` - USB (USB mode)

### Client (Flutter)

- `web_socket_channel` - Network streaming
- `cached_network_image` - Image display
- `flutter_rust_bridge` - Rust interop (optional)
- `usb_serial` - USB on Android (if needed)

---

## Development Order

1. ✅ **Protocol** (1 week) - Foundation
2. ✅ **Server - Capture** (1-2 weeks) - Core functionality
3. ✅ **Server - Transport** (1 week) - Network/USB
4. ✅ **Server - Integration** (1 week) - Complete server
5. ✅ **Client - Basic** (1-2 weeks) - Display frames
6. ✅ **Client - Platform Builds** (1 week) - Android/macOS
7. ⚡ **USB Implementation** (2 weeks) - If needed
8. 🚀 **Optimization** (Ongoing) - Performance tuning

---

## Quick Start Commands

```bash
# Day 1: Setup
cargo new --lib protocol
cargo new server
flutter create client

# Add protocol to server
cd server
cargo add --path ../protocol

# Run server (later)
cargo run

# Run client (later)
cd ../client
flutter run -d macos  # or android
```

---

## Testing Milestones

- [ ] Protocol serializes/deserializes correctly
- [ ] Server captures screen and saves to file
- [ ] Server streams to netcat/VLC
- [ ] Flutter app displays static image from server
- [ ] Flutter app displays continuous stream
- [ ] App runs on Android device
- [ ] App runs on second macOS
- [ ] USB connection established (if applicable)
- [ ] Latency < 100ms
- [ ] Stable 30 FPS streaming

---

## Alternative Approach: Start with MVP

If you want faster results, try this order:

1. **Server**: Capture screen → encode as JPEG → HTTP endpoint
2. **Client**: Flutter app that fetches JPEG every 100ms
3. **Upgrade**: Switch to WebSocket/TCP for streaming
4. **Optimize**: Add H.264, reduce latency

This gets you a working (albeit laggy) version in ~3 days.

---

## Additional Resources

- [Building a Screen Sharing App](https://webrtc.github.io/samples/src/content/capture/canvas-record/)
- [Rust Async Book](https://rust-lang.github.io/async-book/)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [macOS Screen Capture Guide](https://developer.apple.com/documentation/screencapturekit/capturing_screen_content_in_macos)

Good luck! Start with the protocol, test each phase independently, and iterate quickly.
