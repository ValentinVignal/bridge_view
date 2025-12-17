# Bridge View Server

The Rust-based server application for the Bridge View display extension system. Runs on the main MacBook to capture screen content and stream it to connected client devices.

## Overview

The server is responsible for:

- Capturing screen regions using macOS CoreGraphics APIs
- Managing virtual displays for extended screen support
- Encoding video frames using H.264
- Streaming frames to connected clients via WebSocket
- Receiving and injecting input events from clients
- Managing multiple simultaneous client connections

## Features

- **Screen Capture**: Uses `CGDisplayStream` for efficient screen capture
- **Video Encoding**: H.264 encoding with low-latency configuration
- **WebSocket Server**: Real-time bidirectional communication
- **Multi-Client Support**: Handle up to 3 simultaneous clients
- **Input Injection**: Process mouse, keyboard, and touch events from clients
- **Virtual Display Management**: Create and configure extended displays

## Requirements

- macOS (tested on latest version)
- Rust (latest stable version)
- Protocol Buffer compiler (`protoc`)

## Dependencies

Key Rust crates used:

- `tokio` - Async runtime
- `tokio-tungstenite` - WebSocket server
- `prost` - Protocol Buffers
- `core-graphics` - macOS screen capture (planned)
- `openh264` or `ffmpeg` - Video encoding (planned)

## Building

```bash
# From the server directory
cargo build

# For release build
cargo build --release
```

## Running

```bash
# Development
cargo run

# Release
cargo run --release
```

## Configuration

Configuration will be stored in:

- macOS: `~/Library/Application Support/BridgeView/server.toml`

## Development Status

This project is in active development. See [implementation-plan.md](../doc/implementation-plan.md) for the roadmap.

Currently implementing:

- Phase 2: Basic display capture
- Phase 3: Network layer and streaming

## Architecture

```
┌─────────────────────────────────────┐
│         Server (Main Mac)           │
│                                     │
│  ┌──────────────┐  ┌─────────────┐ │
│  │   Display    │  │   Virtual   │ │
│  │   Capture    │  │   Display   │ │
│  └──────┬───────┘  └─────────────┘ │
│         │                           │
│  ┌──────▼───────┐                  │
│  │   Video      │                  │
│  │   Encoder    │                  │
│  └──────┬───────┘                  │
│         │                           │
│  ┌──────▼───────────────────┐      │
│  │   WebSocket Server       │      │
│  │  (tokio-tungstenite)     │      │
│  └──────┬───────────────────┘      │
└─────────┼────────────────────────────┘
          │
    ┌─────┴─────┬─────────────┬──────────┐
    │           │             │          │
┌───▼───┐   ┌───▼───┐    ┌───▼───┐     │
│Client1│   │Client2│    │Client3│     │
│Android│   │Android│    │ macOS │     │
└───────┘   └───────┘    └───────┘     │
```

## Testing

```bash
# Run tests
cargo test

# Run with logging
RUST_LOG=debug cargo run
```

## Contributing

See the main project [README](../README.md) for contribution guidelines.

## License

TBD
