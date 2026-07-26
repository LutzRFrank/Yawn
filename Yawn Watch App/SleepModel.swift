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

    var bedAssetName: String {
        switch score {
        case 80...: "BedTidy"
        case 60..<80: "BedUsed"
        default: "BedPoor"
        }
    }

    static let placeholder = SleepSummary(score: 82, bedState: .okay)
}

enum SleepScore {
    static func summary(total: TimeInterval, awake: TimeInterval, deep: TimeInterval, rem: TimeInterval) -> SleepSummary {
        guard total > 0 else { return SleepSummary(score: 0, bedState: .exhausted) }
        let hours = total / 3600
        let duration = max(0, 1 - abs(hours - 8) / 4) * 50
        let efficiency = min(max((total / max(total + awake, 1) - 0.65) / 0.3, 0), 1) * 30
        let stages = min(((deep + rem) / total) / 0.35, 1) * 20
        let score = min(100, max(0, Int((duration + efficiency + stages).rounded())))
        let state: BedState = score >= 85 ? .refreshed : score >= 70 ? .okay : score >= 50 ? .restless : .exhausted
        return SleepSummary(score: score, bedState: state)
    }
}
