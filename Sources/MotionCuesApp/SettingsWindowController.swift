import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController {
    init(model: AppModel) {
        let rootView = SettingsView(model: model)
        let hostingView = NSHostingView(rootView: rootView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 360),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Motion Cues Settings"
        window.center()
        window.contentView = hostingView

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        nil
    }
}
