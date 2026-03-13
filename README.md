# Motion Cues for macOS (Vehicle Motion Cues Clone)

Menu bar utility for Apple Silicon Macs that overlays subtle edge dots which move with real motion. Motion is streamed from an iPhone using CoreMotion.

## Demo
- The macOS app renders a transparent, click-through overlay above all windows.
- The iPhone companion app streams `userAcceleration` over UDP to drive the animation.

## Requirements
- macOS 13+ (SwiftPM app)
- iOS 17+ for the streamer app (Xcode project in `iOS/`)
- Mac and iPhone on the same Wi-Fi network

## Run (macOS)
```bash
cd "/Users/danyaalsahi/Documents/Motion Sickness"
swift run
```

Then click the menu bar icon and open Settings.

## Run (iPhone streamer)
1. Open `iOS/MotionCuesPhone.xcodeproj` in Xcode.
2. Select your iPhone as the run target and press Run.
3. In the iPhone app, enter your Mac IP (shown in the macOS Settings footer) and tap Start Streaming.
4. In macOS Settings, set Motion Source to iPhone.

## Controls
- Enable/disable from the menu bar.
- Tune intensity, dot size, opacity, smoothing, and dot density in Settings.

## How It Works
- iPhone: CoreMotion `deviceMotion` provides `userAcceleration` at 60 Hz.
- Transport: UDP JSON payloads `{ t, x, y }` sent to the Mac on port `5555`.
- macOS: a smoothing filter reduces jitter, then the overlay maps motion to dot offsets near the screen edges.

## Repo Layout
- `Sources/MotionCuesApp/`: macOS menu bar app + overlay renderer
- `iOS/`: iPhone streamer app (Xcode project) + `Project.yml` for regeneration via `xcodegen`

## Notes
- This is an independent project and is not affiliated with Apple.
- UDP is used for low latency; reliability is intentionally best-effort.

