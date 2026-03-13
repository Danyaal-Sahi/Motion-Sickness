import Foundation

final class MotionProcessor {
    var smoothing: Double
    private var lastTimestamp: Double?
    private var filtered = MotionVector.zero

    init(smoothing: Double) {
        self.smoothing = smoothing
    }

    func process(_ sample: MotionSample) -> MotionVector {
        let dt: Double
        if let lastTimestamp {
            dt = max(0, sample.timestamp - lastTimestamp)
        } else {
            dt = 0
        }
        lastTimestamp = sample.timestamp

        if dt == 0 {
            filtered = sample.vector
            return filtered
        }

        let timeConstant = max(0.01, smoothing)
        let alpha = 1.0 - exp(-dt / timeConstant)
        filtered = filtered + (sample.vector - filtered) * alpha
        return filtered
    }
}
