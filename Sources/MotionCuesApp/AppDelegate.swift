import AppKit
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = AppModel()
    private var overlayController: OverlayWindowController?
    private var settingsController: SettingsWindowController?
    private var statusItem: NSStatusItem?
    private var enabledMenuItem: NSMenuItem?
    private var motionController: MotionController?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayController = OverlayWindowController(model: model)
        motionController = MotionController(model: model)

        setupStatusItem()
        bindModel()

        overlayController?.applyVisibility(isVisible: model.isEnabled)
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "dot.radiowaves.left.and.right", accessibilityDescription: "Motion Cues")
            button.toolTip = "Motion Cues"
        }

        let menu = NSMenu()
        let enabledItem = NSMenuItem(title: "Enable Motion Cues", action: #selector(toggleEnabled), keyEquivalent: "")
        enabledItem.target = self
        enabledItem.state = model.isEnabled ? .on : .off
        menu.addItem(enabledItem)
        enabledMenuItem = enabledItem

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Open Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Motion Cues", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        statusItem = item
    }

    private func bindModel() {
        model.$isEnabled
            .removeDuplicates()
            .sink { [weak self] enabled in
                guard let self else { return }
                self.enabledMenuItem?.state = enabled ? .on : .off
                self.overlayController?.applyVisibility(isVisible: enabled)
            }
            .store(in: &cancellables)
    }

    @objc private func toggleEnabled() {
        model.isEnabled.toggle()
    }

    @objc private func openSettings() {
        if settingsController == nil {
            settingsController = SettingsWindowController(model: model)
        }
        settingsController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
