import Foundation

final class MotionSimulator: MotionSource {
    private var displayLink: DisplayLink?
    private var startTime: Double?

    var frequencyX: Double = 0.12
    var frequencyY: Double = 0.18
    var amplitude: Double = 1.0

    func start(_ handler: @escaping (MotionSample) -> Void) {
        displayLink = DisplayLink()
        displayLink?.start { [weak self] timestamp in
            guard let self else { return }
            if self.startTime == nil {
                self.startTime = timestamp
            }
            let elapsed = timestamp - (self.startTime ?? timestamp)
            let x = sin(2.0 * .pi * self.frequencyX * elapsed) * self.amplitude
            let y = sin(2.0 * .pi * self.frequencyY * elapsed + (.pi / 3.0)) * self.amplitude
            let sample = MotionSample(timestamp: timestamp, vector: MotionVector(x: x, y: y))
            handler(sample)
        }
    }

    func stop() {
        displayLink?.stop()
        displayLink = nil
        startTime = nil
    }
}
