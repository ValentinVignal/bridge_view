# macOS Virtual Display Research

## Overview

This document outlines research findings for creating virtual displays on macOS for the Bridge View project.

## Display Detection POC

Created a proof-of-concept in `server/src/main.rs` that uses CoreGraphics APIs to:

- Detect the main display
- Enumerate all active displays
- Query display properties (resolution, position, refresh rate, etc.)

### Running the POC

```bash
cd server
cargo run
```

## macOS Virtual Display Options

### 1. **Hardware External Displays (Recommended for MVP)**

**Approach**: Use physical external monitors or adapters

- Connect monitors via USB-C/Thunderbolt/HDMI
- macOS automatically creates extended displays
- Server captures these physical displays and streams to clients

**Pros**:

- Simple, no custom driver needed
- Native macOS support
- Reliable and stable
- Works immediately

**Cons**:

- Requires physical monitors to be connected
- Resolution fixed by monitor capabilities
- Not truly "virtual"

**Implementation**:

- Already working - detect displays with CoreGraphics
- No additional development needed for display creation

### 2. **CoreGraphics Display Configuration**

**API**: `CGConfigureDisplayMode`, `CGBeginDisplayConfiguration`, `CGConfigureDisplayWithDisplayMode`

**Approach**: Use CoreGraphics APIs to programmatically configure existing displays

**Capabilities**:

- Change resolution of existing displays
- Reposition displays
- Enable/disable displays
- Modify refresh rates

**Limitations**:

- **Cannot create new virtual displays from scratch**
- Can only modify existing physical displays
- Requires physical display hardware

**Status**: ❌ Not suitable for creating virtual displays

### 3. **Third-Party Virtual Display Drivers**

#### BetterDisplay / BetterDummy

- Open-source dummy display driver
- Creates virtual displays via kernel extension or DriverKit
- Allows custom resolutions
- URL: https://github.com/waydabber/BetterDisplay

**Pros**:

- Can create true virtual displays
- Custom resolutions
- Actively maintained

**Cons**:

- Requires separate installation
- May require disabling SIP (System Integrity Protection)
- Additional dependency

#### DisplayLink

- Commercial solution for virtual displays
- Primarily for USB display adapters
- Could potentially be used for virtual displays

**Cons**:

- Commercial/proprietary
- Not designed for this use case

### 4. **Dummy HDMI/USB-C Plugs**

**Hardware Solution**: HDMI dummy plug or USB-C display emulator

- Small hardware device that emulates a display
- Cheap ($10-20)
- Tricks macOS into thinking a display is connected
- Available on Amazon/AliExpress

**Pros**:

- Simple, no software complexity
- Works reliably
- No special permissions needed
- Custom EDIDs possible

**Cons**:

- Requires physical hardware per display
- Manual setup required

### 5. **Sidecar/Universal Control APIs**

**Apple's Approach**: Use iPad as extended display

- Uses private APIs
- Not publicly accessible
- Reverse engineering would be complex and fragile

**Status**: ❌ Not feasible

## Recommended Approach for Bridge View

### Phase 1 (MVP): Physical Displays

1. Require user to connect physical monitors OR use dummy HDMI plugs
2. Server detects all displays via CoreGraphics
3. User configures which displays to stream to which clients
4. Server captures assigned displays and streams to clients

**Advantages**:

- Can implement immediately
- No driver complexity
- Stable and reliable
- Meets all functional requirements

### Phase 2 (Future): Investigate Driver-based Virtual Displays

- Research DriverKit (Apple's modern driver framework)
- Consider integrating with BetterDisplay
- Or develop custom DriverKit virtual display driver

**Note**: Driver development requires:

- Paid Apple Developer account
- Code signing
- User acceptance of driver installation
- Significant complexity

## CoreGraphics Display APIs Used

```rust
use core_graphics::display::CGDisplay;

// Get main display
let main = CGDisplay::main();

// Get all active displays
let displays = CGDisplay::active_displays()?;

// Display properties
display.bounds()           // Position and size
display.display_mode()     // Resolution, refresh rate
display.is_builtin()       // Built-in vs external
display.is_active()        // Currently active
```

## Display Capture APIs (Next Step)

For Phase 2.2 (Screen Capture Implementation):

```rust
// Use CGDisplayStream for efficient capture
// - Low latency
// - Hardware accelerated
// - Frame callbacks
// - Works with any display
```

APIs to research:

- `CGDisplayStreamCreateWithDispatchQueue`
- `CGDisplayStreamStart`
- `CGDisplayStreamStop`

## Implementation Decision

**For MVP**: Use physical external displays or dummy HDMI plugs

- User connects displays (real or dummy)
- Server detects and captures them
- Stream to clients

This allows us to:

- Build and test the entire streaming pipeline
- Validate the architecture
- Ship a working product quickly
- Add true virtual display support later if needed

## References

- [CoreGraphics Display Services](https://developer.apple.com/documentation/coregraphics/quartz_display_services)
- [BetterDisplay on GitHub](https://github.com/waydabber/BetterDisplay)
- [DriverKit Documentation](https://developer.apple.com/documentation/driverkit)
- [Dummy HDMI Plugs](https://www.amazon.com/s?k=hdmi+dummy+plug)

## Next Steps

See [implementation-plan.md](implementation-plan.md):

- ✅ Step 2.1: Virtual display research (completed)
- → Step 2.2: Screen capture implementation using CGDisplayStream
- → Step 2.3: Video encoding
