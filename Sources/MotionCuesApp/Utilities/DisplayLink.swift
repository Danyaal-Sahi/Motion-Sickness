import Foundation
import CoreVideo

final class DisplayLink {
    private var displayLink: CVDisplayLink?
    private var isRunning = false
    private var tickHandler: ((Double) -> Void)?

    init?() {
        var link: CVDisplayLink?
        let status = CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard status == kCVReturnSuccess, let created = link else { return nil }
        displayLink = created
    }

    func start(_ handler: @escaping (Double) -> Void) {
        guard let displayLink else { return }
        guard !isRunning else { return }
        tickHandler = handler

        let callback: CVDisplayLinkOutputCallback = { _, _, outputTime, _, _, context in
            let timestamp = Double(outputTime.pointee.hostTime) / Double(CVGetHostClockFrequency())
            let unmanaged = Unmanaged<DisplayLink>.fromOpaque(context!)
            unmanaged.takeUnretainedValue().handleTick(timestamp)
            return kCVReturnSuccess
        }

        CVDisplayLinkSetOutputCallback(displayLink, callback, Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkStart(displayLink)
        isRunning = true
    }

    func stop() {
        guard let displayLink else { return }
        guard isRunning else { return }
        CVDisplayLinkStop(displayLink)
        isRunning = false
    }

    private func handleTick(_ timestamp: Double) {
        guard let tickHandler else { return }
        DispatchQueue.main.async {
            tickHandler(timestamp)
        }
    }
}
