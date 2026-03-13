import Foundation
import Network

final class MotionNetworkSource: MotionSource {
    private let port: NWEndpoint.Port
    private var listener: NWListener?
    private var queue = DispatchQueue(label: "motioncues.network")

    init(port: UInt16 = 5555) {
        self.port = NWEndpoint.Port(rawValue: port) ?? 5555
    }

    func start(_ handler: @escaping (MotionSample) -> Void) {
        do {
            let listener = try NWListener(using: .udp, on: port)
            self.listener = listener

            listener.newConnectionHandler = { connection in
                connection.stateUpdateHandler = { state in
                    if case .failed = state {
                        connection.cancel()
                    }
                }
                connection.start(queue: self.queue)
                self.receive(on: connection, handler: handler)
            }

            listener.stateUpdateHandler = { _ in }
            listener.start(queue: queue)
        } catch {
            // No-op for now; caller can fall back to simulator if desired.
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func receive(on connection: NWConnection, handler: @escaping (MotionSample) -> Void) {
        connection.receiveMessage { [weak self] data, _, _, _ in
            guard let self else { return }
            if let data, let sample = self.decodeSample(data) {
                handler(sample)
            }
            self.receive(on: connection, handler: handler)
        }
    }

    private func decodeSample(_ data: Data) -> MotionSample? {
        struct Payload: Decodable {
            let t: Double
            let x: Double
            let y: Double
        }

        guard let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            return nil
        }

        let vector = MotionVector(x: payload.x, y: payload.y)
        return MotionSample(timestamp: payload.t, vector: vector)
    }
}
