# Bridge View Client

The Flutter-based client application for the Bridge View display extension system. Runs on Android phones and macOS devices to display extended screen content from the main MacBook.

## Overview

The client is responsible for:

- Connecting to the Bridge View server via WebSocket
- Receiving and decoding H.264 video streams
- Rendering frames in fullscreen mode
- Capturing and sending input events (touch, mouse, keyboard)
- Managing connection state and reconnection

## Supported Platforms

- **Android**: Phones/tablets (primary use case)
- **macOS**: Additional MacBook as extended display
- **iOS**: Planned for future
- **Linux/Windows**: Potential future support

## Features

- **Video Decoding**: Real-time H.264 stream decoding
- **Fullscreen Rendering**: Optimized display with no UI chrome
- **Input Capture**: Touch, mouse, and keyboard event handling
- **Auto-reconnect**: Robust connection management
- **USB-C Networking**: Low-latency connection via USB tethering
- **WiFi Fallback**: Automatic fallback to wireless connection

## Requirements

- Flutter SDK (latest stable)
- Dart SDK (comes with Flutter)
- Protocol Buffer compiler (`protoc`) with Dart plugin

For Android:

- Android SDK
- Minimum SDK version: 21 (Android 5.0)

For macOS:

- macOS 10.14+
- Xcode (for building)

## Building

```bash
# Get dependencies
flutter pub get

# Generate protobuf code (if needed)
cd ../protocol
make dart

# Run in debug mode
flutter run

# Build for Android
flutter build apk

# Build for macOS
flutter build macos
```

## Running

### Development Mode

```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d <device_id>
```

### Release Mode

```bash
# Android APK
flutter build apk --release

# macOS app
flutter build macos --release
```

## Configuration

The app will connect to the server using:

- **USB-C**: Auto-detected via mDNS or static IP
- **WiFi**: Manual IP configuration or mDNS discovery

Connection settings can be configured in the app UI.

## Project Structure

```
lib/
├── main.dart              # App entry point
├── proto/                 # Generated protobuf code
├── screens/               # UI screens (planned)
├── services/              # Business logic (planned)
│   ├── connection_service.dart
│   ├── video_service.dart
│   └── input_service.dart
└── widgets/               # Reusable widgets (planned)
```

## Development Status

This project is in active development. See [implementation-plan.md](../doc/implementation-plan.md) for the roadmap.

Currently implementing:

- Phase 4: Basic rendering and connection
- Phase 5: Input handling

## Dependencies

Key Flutter packages used:

- `protobuf` - Protocol Buffers support
- `web_socket_channel` - WebSocket client
- `video_player` - Video playback (planned)
- `wakelock` - Prevent screen sleep (planned)

## Testing

```bash
# Run tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

## Platform-Specific Setup

### Android

- USB debugging enabled
- USB tethering configured for network access
- Allow app to run in fullscreen without system UI

### macOS

- Network sharing configured for USB-C connection
- Allow app to capture keyboard/mouse events
- Configure as trusted device

## Troubleshooting

**Cannot connect to server:**

- Verify USB-C connection and network sharing
- Check server is running on main MacBook
- Try manual IP configuration

**Video playback issues:**

- Ensure device supports H.264 decoding
- Check network bandwidth and latency
- Try lowering video quality settings

**Input not working:**

- Verify input permissions are granted
- Check coordinate transformation settings
- Ensure server is receiving input events

## Contributing

See the main project [README](../README.md) for contribution guidelines.

## License

TBD
