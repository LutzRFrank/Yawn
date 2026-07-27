import Foundation

enum BedState: Sendable {
    case exhausted, restless, okay, refreshed

    var assetName: String {
        switch self {
        case .exhausted: "BedExhausted"
        case .restless: "BedRestless"
        case .okay: "BedOkay"
        case .refreshed: "BedRefreshed"
        }
    }

    var characterAssetName: String {
        switch self {
        case .exhausted: "GuyExhausted"
        case .restless: "GuyRestless"
        case .okay: "GuyOkay"
        case .refreshed: "GuyRefreshed"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .exhausted: "Sehr zerwühltes Bett"
        case .restless: "Unruhiges Bett"
        case .okay: "Leicht zerknittertes Bett"
        case .refreshed: "Ordentliches Bett"
        }
    }
}

struct SleepSummary: Sendable {
    let score: Int
    let bedState: BedState

    init(score: Int) {
        self.score = score
        bedState = score >= 85 ? .refreshed : score >= 70 ? .okay : score >= 50 ? .restless : .exhausted
    }

    var bedAssetName: String {
        switch score {
        case 80...: "BedTidy"
        case 60..<80: "BedUsed"
        default: "BedPoor"
        }
    }

    static let placeholder = SleepSummary(score: 82)
}

enum SleepScore {
    static func summary(
        totalSleep: TimeInterval,
        bedtimeConsistency: TimeInterval,
        awake: TimeInterval,
        interruptionCount: Int
    ) -> SleepSummary {
        guard totalSleep > 0 else {
            return SleepSummary(score: 0)
        }

        let hours = totalSleep / 3600
        let durationQuality = min(1, max(0, (hours - (3 + 1.0 / 3)) / 4))
        let duration = durationQuality * 50

        let deviationMinutes = max(0, bedtimeConsistency / 60)
        let timing = max(0, 1 - max(0, deviationMinutes - 15) / 110) * 30

        let awakeMinutes = max(0, awake / 60)
        let durationPenalty = awakeMinutes / 11
        let countPenalty = Double(max(0, interruptionCount - 1)) * 0.8
        let interruptions = max(0, 20 - durationPenalty - countPenalty)

        let score = min(
            100,
            max(
                0,
                Int(duration.rounded())
                    + Int(timing.rounded())
                    + Int(interruptions.rounded())
            )
        )
        return SleepSummary(score: score)
    }
}
