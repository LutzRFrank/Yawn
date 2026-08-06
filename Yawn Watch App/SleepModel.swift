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

        let minutes = max(0, totalSleep / 60)
        let duration: Double
        switch minutes {
        case 480...:
            duration = 50
        case 450..<480:
            duration = 48 + (minutes - 450) / 15
        case 420..<450:
            duration = 45 + (minutes - 420) / 10
        case 360..<420:
            duration = 35 + (minutes - 360) / 6
        default:
            duration = max(0, (minutes - 200) * 35 / 160)
        }

        let minutesLater = max(0, bedtimeConsistency / 60)
        let timing = max(0, 30 - max(0, minutesLater - 15) / 6)

        let awakeMinutes = max(0, awake / 60)
        let durationPenalty = awakeMinutes / 20
        let countPenalty = Double(max(0, interruptionCount - 4)) * 2
        let interruptions = max(0, 20 - max(durationPenalty, countPenalty))

        let score = min(
            100,
            max(
                0,
                Int(min(50, duration).rounded(.down))
                    + Int(timing.rounded())
                    + Int(interruptions.rounded(.down))
            )
        )
        return SleepSummary(score: score)
    }
}
