import Foundation
import CoreMotion
import Network

final class MotionStreamer: ObservableObject {
    @Published var isStreaming: Bool = false
    @Published var lastError: String?

    private let motionManager = CMMotionManager()
    private var connection: NWConnection?
    private let queue = OperationQueue()

    func startStreaming(to host: String, port: UInt16 = 5555) {
        stopStreaming()
        lastError = nil

        guard motionManager.isDeviceMotionAvailable else {
            lastError = "Device motion unavailable"
            return
        }

        let endpoint = NWEndpoint.Host(host)
        let nwPort = NWEndpoint.Port(rawValue: port) ?? 5555
        let connection = NWConnection(host: endpoint, port: nwPort, using: .udp)
        self.connection = connection
        connection.start(queue: .global())

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: queue) { [weak self] motion, error in
            if let error {
                DispatchQueue.main.async {
                    self?.lastError = error.localizedDescription
                }
                return
            }
            guard let motion else { return }
            let ax = motion.userAcceleration.x
            let ay = motion.userAcceleration.y
            let timestamp = motion.timestamp

            let payload = Payload(t: timestamp, x: ax, y: ay)
            guard let data = try? JSONEncoder().encode(payload) else { return }
            connection.send(content: data, completion: .contentProcessed { _ in })

            DispatchQueue.main.async {
                self?.isStreaming = true
            }
        }
    }

    func stopStreaming() {
        motionManager.stopDeviceMotionUpdates()
        connection?.cancel()
        connection = nil
        isStreaming = false
    }

    private struct Payload: Codable {
        let t: Double
        let x: Double
        let y: Double
    }
}
