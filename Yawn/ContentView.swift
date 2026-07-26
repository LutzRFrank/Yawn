import SwiftUI

struct ContentView: View {
    @State private var sleep = SleepSummary.placeholder
    @State private var healthMessage: String?

    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.945, blue: 0.91)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                ZStack(alignment: .bottomLeading) {
                    Image(sleep.bedAssetName)
                        .resizable()
                        .scaledToFit()

                    Image(sleep.bedState.characterAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                        .offset(x: -2, y: 28)
                }
                .contentTransition(.opacity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(sleep.bedState.accessibilityLabel)

                Text("\(sleep.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.indigo)
                    .contentTransition(.numericText())
                    .accessibilityLabel("Sleep Score \(sleep.score)")
                    .offset(y: -8)

                HStack(spacing: 10) {
                    SleepMetricCard(
                        title: "Dauer",
                        value: "\(sleep.durationPoints)/50",
                        detail: sleep.sleepDurationText,
                        color: .indigo
                    )
                    SleepMetricCard(
                        title: "Effizienz",
                        value: "\(sleep.efficiencyPoints)/30",
                        detail: "\(sleep.awakeDurationText) wach",
                        color: .cyan
                    )
                    SleepMetricCard(
                        title: "Erholung",
                        value: "\(sleep.restorationPoints)/20",
                        detail: sleep.restorativeShareText,
                        color: .orange
                    )
                }
                .offset(y: -8)

                if let healthMessage {
                    Text(healthMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(24)
        }
        .task {
            do {
                sleep = try await SleepHealthStore.shared.latestNight()
                healthMessage = nil
            } catch {
                healthMessage = "Health-Zugriff erlauben, um die letzte Nacht anzuzeigen."
            }
        }
    }
}

private struct SleepMetricCard: View {
    let title: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
            }

            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))

            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.55), lineWidth: 0.8)
        }
    }
}

#Preview {
    ContentView()
}
