import Foundation
import Combine

final class MotionController {
    private var source: MotionSource
    private let processor: MotionProcessor
    private weak var model: AppModel?
    private var cancellables = Set<AnyCancellable>()
    private var isRunning = false

    init(model: AppModel) {
        self.model = model
        self.source = MotionController.makeSource(type: model.motionSource)
        self.processor = MotionProcessor(smoothing: model.smoothing)

        model.$smoothing
            .removeDuplicates()
            .sink { [weak self] value in
                self?.processor.smoothing = value
            }
            .store(in: &cancellables)

        model.$motionSource
            .removeDuplicates()
            .sink { [weak self] type in
                self?.switchSource(to: type)
            }
            .store(in: &cancellables)

        model.$isEnabled
            .removeDuplicates()
            .sink { [weak self] enabled in
                if enabled {
                    self?.start()
                } else {
                    self?.stop()
                }
            }
            .store(in: &cancellables)

        if model.isEnabled {
            start()
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        source.start { [weak self] sample in
            guard let self, let model = self.model else { return }
            let vector = self.processor.process(sample).clamped(1.0)
            model.motionVector = vector
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        source.stop()
        model?.motionVector = .zero
    }

    private func switchSource(to type: MotionSourceType) {
        let wasRunning = isRunning
        stop()
        source = MotionController.makeSource(type: type)
        if wasRunning {
            start()
        }
    }

    private static func makeSource(type: MotionSourceType) -> MotionSource {
        switch type {
        case .simulation:
            return MotionSimulator()
        case .iphone:
            return MotionNetworkSource()
        }
    }
}
