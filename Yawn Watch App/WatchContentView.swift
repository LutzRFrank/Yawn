import SwiftUI

struct WatchContentView: View {
    @State private var sleep = SleepSummary.placeholder

    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .bottomLeading) {
                Image(sleep.bedAssetName)
                    .resizable()
                    .scaledToFit()

                Image(sleep.bedState.characterAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88)
                    .offset(x: -4, y: 10)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(sleep.bedState.accessibilityLabel)

            Text("\(sleep.score)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.indigo)
                .accessibilityLabel("Sleep Score \(sleep.score)")
                .offset(y: -4)
        }
        .containerBackground(
            Color(red: 0.965, green: 0.945, blue: 0.91),
            for: .navigation
        )
        .task {
            if let summary = try? await SleepHealthStore.shared.latestNight() {
                sleep = summary
            }
        }
    }
}
