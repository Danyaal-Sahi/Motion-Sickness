import Foundation

struct MotionSample {
    let timestamp: Double
    let vector: MotionVector
}

protocol MotionSource {
    func start(_ handler: @escaping (MotionSample) -> Void)
    func stop()
}
