# Bridge View Protocol

This directory contains the Protocol Buffer definitions for the Bridge View display extension system.

## Overview

The protocol defines communication between:

- **Server** (Main MacBook running Rust): Captures and streams display content
- **Clients** (Android phones and extra MacBook running Flutter): Receive and render display streams

## Protocol Buffers

### `proto/display.proto`

Defines the complete communication protocol including:

1. **Service Definition** (`DisplayService`)

   - `RegisterClient`: Client registration and configuration
   - `StreamFrames`: Bidirectional video frame streaming
   - `SendInput`: Input event streaming from client to server
   - `SendControl`: Connection management and control messages

2. **Message Types**
   - `ClientRegistration`: Client info and capabilities
   - `DisplayConfig`: Display configuration from server
   - `VideoFrame`: Encoded video frame data
   - `InputEvent`: Mouse/keyboard/touch events
   - `ControlMessage`: Connection control and heartbeat

## Code Generation

### For Rust (Server)

```bash
# Install protoc compiler and Rust plugin
brew install protobuf
cargo install protobuf-codegen

# Generate Rust code
cd protocol
protoc --rust_out=../server/src/proto proto/display.proto
```

### For Dart (Flutter Client)

```bash
# Install protoc compiler and Dart plugin
brew install protobuf
dart pub global activate protoc_plugin

# Add to PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Generate Dart code
cd protocol
protoc --dart_out=../client/lib/proto proto/display.proto
```

## Protocol Flow

### 1. Client Registration

```
Client → RegisterClient(capabilities) → Server
Client ← DisplayConfig(resolution, position) ← Server
```

### 2. Video Streaming

```
Client → FrameRequest(continue) → Server
Client ← VideoFrame(encoded_data) ← Server
Client ← VideoFrame(encoded_data) ← Server
...
```

### 3. Input Events

```
Client → InputEvent(mouse/touch/keyboard) → Server
Client ← InputResponse(success) ← Server
```

### 4. Heartbeat

```
Client → ControlMessage(heartbeat) → Server
Client ← ControlResponse(timestamp) ← Server
```

## Coordinate System

- Input event coordinates are **normalized** (0.0 to 1.0) relative to the client display
- Server transforms these to absolute coordinates in the virtual display space
- This ensures resolution-independence

## Supported Codecs

- H.264 (primary)
- H.265/HEVC (optional, better compression)
- VP8/VP9 (optional, open codec)

## Versioning

Protocol version is managed through the package version. Breaking changes require a new package version and backward compatibility handling.
