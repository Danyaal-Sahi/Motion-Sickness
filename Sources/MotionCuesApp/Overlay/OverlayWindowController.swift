import AppKit
import Combine

final class OverlayWindowController: NSWindowController {
    private let model: AppModel
    private var overlayView: OverlayView
    private var cancellables = Set<AnyCancellable>()

    init(model: AppModel) {
        self.model = model
        let frame = NSScreen.main?.frame ?? .zero
        let window = NSWindow(
            contentRect: frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .screenSaver
        window.ignoresMouseEvents = true
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]

        overlayView = OverlayView(frame: frame, model: model)
        window.contentView = overlayView

        super.init(window: window)

        bindScreenChanges()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func applyVisibility(isVisible: Bool) {
        guard let window else { return }
        if isVisible {
            window.orderFrontRegardless()
        } else {
            window.orderOut(nil)
        }
    }

    private func bindScreenChanges() {
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.updateFrame()
            }
            .store(in: &cancellables)
    }

    private func updateFrame() {
        guard let screenFrame = NSScreen.main?.frame else { return }
        window?.setFrame(screenFrame, display: true)
        overlayView.frame = screenFrame
        overlayView.needsLayout = true
    }
}
