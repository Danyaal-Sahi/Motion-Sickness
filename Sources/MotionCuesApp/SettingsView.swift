import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Enable Motion Cues", isOn: $model.isEnabled)

            Picker("Motion Source", selection: $model.motionSource) {
                ForEach(MotionSourceType.allCases) { source in
                    Text(source.title).tag(source)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading) {
                Text("Intensity")
                Slider(value: $model.intensity, in: 0.1...1.0, step: 0.05)
            }

            VStack(alignment: .leading) {
                Text("Dot Size")
                Slider(value: $model.dotSize, in: 6...28, step: 1)
            }

            VStack(alignment: .leading) {
                Text("Dot Opacity")
                Slider(value: $model.dotOpacity, in: 0.2...1.0, step: 0.05)
            }

            VStack(alignment: .leading) {
                Text("Smoothing (seconds)")
                Slider(value: $model.smoothing, in: 0.05...0.8, step: 0.05)
            }

            VStack(alignment: .leading) {
                Text("Dots Per Edge")
                Slider(value: Binding(
                    get: { Double(model.dotsPerEdge) },
                    set: { model.dotsPerEdge = Int($0) }
                ), in: 4...16, step: 1)
            }

            HStack {
                Spacer()
                Text(footerText)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private var footerText: String {
        if model.motionSource == .iphone {
            let addresses = NetworkInfo.localIPv4Addresses()
            let addressText = addresses.first ?? "Check Wi‑Fi"
            return "Mac IP: \(addressText)  •  UDP 5555"
        }
        return "Simulation mode"
    }
}
