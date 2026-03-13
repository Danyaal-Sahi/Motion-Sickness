import SwiftUI

struct ContentView: View {
    @StateObject private var streamer = MotionStreamer()
    @State private var host: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Motion Cues Streamer")
                .font(.title2)

            TextField("Mac IP address", text: $host)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .keyboardType(.numbersAndPunctuation)

            Button(streamer.isStreaming ? "Stop Streaming" : "Start Streaming") {
                if streamer.isStreaming {
                    streamer.stopStreaming()
                } else {
                    streamer.startStreaming(to: host)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(host.isEmpty)

            if let error = streamer.lastError {
                Text(error)
                    .foregroundStyle(.red)
            } else {
                Text(streamer.isStreaming ? "Streaming motion data" : "Idle")
                    .foregroundStyle(.secondary)
            }

            Text("Make sure the Mac and iPhone are on the same Wi‑Fi.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
