# MotionCuesPhone (iOS)

This folder contains the iOS app source that streams CoreMotion data over UDP.

## Create the Xcode project
1. Open Xcode and create a new **iOS App** project.
2. Product name: `MotionCuesPhone` (Swift, SwiftUI).
3. Replace the generated files with the contents of:
   - `MotionCuesPhoneApp.swift`
   - `ContentView.swift`
   - `MotionStreamer.swift`
4. Add the **CoreMotion** and **Network** frameworks (Xcode will link them automatically via imports).

## Run
- Put your Mac IP address into the app.
- Tap **Start Streaming**.
- On macOS, select `Motion Source: iPhone` in settings.
