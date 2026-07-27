import SwiftUI

struct WatchContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var sleep = SleepSummary.placeholder
    @State private var sceneChoice = WatchMorningSceneChoice.random()
    @StateObject private var phoneScoreStore = PhoneScoreStore.shared

    var body: some View {
        VStack(spacing: 2) {
            WatchMorningSceneView(sleep: sleep, choice: sceneChoice)
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
            if let score = phoneScoreStore.score {
                sleep = SleepSummary(score: score)
            } else if let summary = try? await SleepHealthStore.shared.latestNight() {
                sleep = summary
            }
        }
        .onReceive(phoneScoreStore.$score.compactMap { $0 }) { score in
            sleep = SleepSummary(score: score)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                sceneChoice = .random()
            }
        }
    }
}

private struct WatchMorningSceneChoice {
    let variant: Int
    let showsLady: Bool

    static func random() -> Self {
        Self(
            variant: Int.random(in: 0..<4),
            showsLady: Int.random(in: 0..<10) == 0
        )
    }

    func sceneAssetName(for state: BedState) -> String? {
        if showsLady, state == .refreshed {
            return "SceneLadyJump"
        }

        return switch state {
        case .exhausted:
            [nil, "SceneExhaustedSlide", "SceneExhaustedHidden", "SceneExhaustedEdgeSit"][variant]
        case .restless:
            [nil, "SceneRestlessPillow", "SceneRestlessTangle", "SceneRestlessPillowHug"][variant]
        case .okay:
            [nil, "SceneOkayStretch", "SceneOkayMakeBed", "SceneOkayWave"][variant]
        case .refreshed:
            [nil, "SceneRefreshedJump", "SceneRefreshedVictory", "SceneRefreshedCape"][variant]
        }
    }
}

private struct WatchMorningSceneView: View {
    let sleep: SleepSummary
    let choice: WatchMorningSceneChoice

    var body: some View {
        if let sceneAssetName = choice.sceneAssetName(for: sleep.bedState) {
            Image(sceneAssetName)
                .resizable()
                .scaledToFit()
        } else {
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
        }
    }
}
