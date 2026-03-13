import Foundation

struct MotionVector: Equatable {
    var x: Double
    var y: Double

    static let zero = MotionVector(x: 0, y: 0)

    func clamped(_ limit: Double) -> MotionVector {
        let clampedX = max(-limit, min(limit, x))
        let clampedY = max(-limit, min(limit, y))
        return MotionVector(x: clampedX, y: clampedY)
    }
}

enum MotionSourceType: String, CaseIterable, Identifiable {
    case simulation
    case iphone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .simulation:
            return "Simulation"
        case .iphone:
            return "iPhone"
        }
    }
}

func +(lhs: MotionVector, rhs: MotionVector) -> MotionVector {
    MotionVector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -(lhs: MotionVector, rhs: MotionVector) -> MotionVector {
    MotionVector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func *(lhs: MotionVector, rhs: Double) -> MotionVector {
    MotionVector(x: lhs.x * rhs, y: lhs.y * rhs)
}
