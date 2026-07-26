import Foundation

enum BedState: Int, CaseIterable, Sendable {
    case exhausted
    case restless
    case okay
    case refreshed

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
    let totalSleep: TimeInterval
    let awake: TimeInterval
    let deep: TimeInterval
    let rem: TimeInterval

    var durationPoints: Int {
        let hours = totalSleep / 3600
        return Int((max(0, 1 - abs(hours - 8) / 4) * 50).rounded())
    }

    var efficiencyPoints: Int {
        let efficiency = totalSleep / max(totalSleep + awake, 1)
        return Int((min(max((efficiency - 0.65) / 0.3, 0), 1) * 30).rounded())
    }

    var restorationPoints: Int {
        guard totalSleep > 0 else { return 0 }
        return Int((min(((deep + rem) / totalSleep) / 0.35, 1) * 20).rounded())
    }

    var sleepDurationText: String {
        Self.durationText(totalSleep)
    }

    var awakeDurationText: String {
        Self.durationText(awake)
    }

    var restorativeShareText: String {
        guard totalSleep > 0 else { return "0 %" }
        return "\(Int((((deep + rem) / totalSleep) * 100).rounded())) %"
    }

    var bedAssetName: String {
        switch score {
        case 80...: "BedTidy"
        case 60..<80: "BedUsed"
        default: "BedPoor"
        }
    }

    var bedState: BedState {
        switch score {
        case 85...: .refreshed
        case 70..<85: .okay
        case 50..<70: .restless
        default: .exhausted
        }
    }

    static let placeholder = SleepSummary(
        score: 82,
        totalSleep: 7.5 * 3600,
        awake: 25 * 60,
        deep: 70 * 60,
        rem: 100 * 60
    )

    private static func durationText(_ duration: TimeInterval) -> String {
        let minutes = max(0, Int((duration / 60).rounded()))
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return hours > 0 ? "\(hours) h \(remainingMinutes) min" : "\(remainingMinutes) min"
    }
}

enum SleepScore {
    static func calculate(
        totalSleep: TimeInterval,
        awake: TimeInterval,
        deep: TimeInterval,
        rem: TimeInterval
    ) -> Int {
        guard totalSleep > 0 else { return 0 }

        let summary = SleepSummary(
            score: 0,
            totalSleep: totalSleep,
            awake: awake,
            deep: deep,
            rem: rem
        )
        return min(100, max(0, summary.durationPoints + summary.efficiencyPoints + summary.restorationPoints))
    }
}
