import Foundation
import Combine

final class AppModel: ObservableObject {
    @Published var isEnabled: Bool
    @Published var motionSource: MotionSourceType
    @Published var intensity: Double
    @Published var dotSize: Double
    @Published var dotOpacity: Double
    @Published var smoothing: Double
    @Published var dotsPerEdge: Int
    @Published var motionVector: MotionVector = .zero

    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    init() {
        let storedEnabled = defaults.object(forKey: "isEnabled") as? Bool
        let storedMotionSource = defaults.string(forKey: "motionSource")
        let storedIntensity = defaults.object(forKey: "intensity") as? Double
        let storedDotSize = defaults.object(forKey: "dotSize") as? Double
        let storedDotOpacity = defaults.object(forKey: "dotOpacity") as? Double
        let storedSmoothing = defaults.object(forKey: "smoothing") as? Double
        let storedDotsPerEdge = defaults.object(forKey: "dotsPerEdge") as? Int

        isEnabled = storedEnabled ?? true
        motionSource = MotionSourceType(rawValue: storedMotionSource ?? "") ?? .simulation
        intensity = storedIntensity ?? 0.7
        dotSize = storedDotSize ?? 12
        dotOpacity = storedDotOpacity ?? 0.7
        smoothing = storedSmoothing ?? 0.25
        dotsPerEdge = storedDotsPerEdge ?? 8

        bindPersistence()
    }

    private func bindPersistence() {
        $isEnabled.dropFirst().sink { [weak self] value in
            self?.defaults.set(value, forKey: "isEnabled")
        }.store(in: &cancellables)

        $motionSource.dropFirst().sink { [weak self] value in
            self?.defaults.set(value.rawValue, forKey: "motionSource")
        }.store(in: &cancellables)

        $intensity.dropFirst().sink { [weak self] value in
            self?.defaults.set(value, forKey: "intensity")
        }.store(in: &cancellables)

        $dotSize.dropFirst().sink { [weak self] value in
            self?.defaults.set(value, forKey: "dotSize")
        }.store(in: &cancellables)

        $dotOpacity.dropFirst().sink { [weak self] value in
            self?.defaults.set(value, forKey: "dotOpacity")
        }.store(in: &cancellables)

        $smoothing.dropFirst().sink { [weak self] value in
            self?.defaults.set(value, forKey: "smoothing")
        }.store(in: &cancellables)

        $dotsPerEdge.dropFirst().sink { [weak self] value in
            self?.defaults.set(value, forKey: "dotsPerEdge")
        }.store(in: &cancellables)
    }
}
