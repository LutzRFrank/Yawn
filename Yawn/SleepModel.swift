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
    let bedtime: Date
    let bedtimeConsistency: TimeInterval
    let awake: TimeInterval
    let interruptionCount: Int

    var durationPoints: Int {
        SleepScore.durationPoints(totalSleep: totalSleep)
    }

    var bedtimePoints: Int {
        SleepScore.bedtimePoints(consistency: bedtimeConsistency)
    }

    var interruptionPoints: Int {
        SleepScore.interruptionPoints(awake: awake, count: interruptionCount)
    }

    var sleepDurationText: String {
        Self.durationText(totalSleep)
    }

    var bedtimeText: String {
        bedtime.formatted(date: .omitted, time: .shortened)
    }

    var interruptionText: String {
        let times = interruptionCount == 1 ? "1×" : "\(interruptionCount)×"
        return "\(times) · \(Self.durationText(awake))"
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
        score: 84,
        totalSleep: 7.5 * 3600,
        bedtime: previewBedtime(hour: 23, minute: 10),
        bedtimeConsistency: 30 * 60,
        awake: 25 * 60,
        interruptionCount: 2
    )

    static let poorPreview = SleepSummary(
        score: 30,
        totalSleep: 4.75 * 3600,
        bedtime: previewBedtime(hour: 2, minute: 5),
        bedtimeConsistency: 2 * 3600,
        awake: 95 * 60,
        interruptionCount: 7
    )

    private static func previewBedtime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: .now
        ) ?? .now
    }

    static func durationText(_ duration: TimeInterval) -> String {
        let minutes = max(0, Int((duration / 60).rounded()))
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return hours > 0 ? "\(hours) h \(remainingMinutes) min" : "\(remainingMinutes) min"
    }
}

enum SleepScore {
    static func calculate(
        totalSleep: TimeInterval,
        bedtimeConsistency: TimeInterval,
        awake: TimeInterval,
        interruptionCount: Int
    ) -> Int {
        guard totalSleep > 0 else { return 0 }

        return min(
            100,
            max(
                0,
                durationPoints(totalSleep: totalSleep)
                    + bedtimePoints(consistency: bedtimeConsistency)
                    + interruptionPoints(awake: awake, count: interruptionCount)
            )
        )
    }

    static func durationPoints(totalSleep: TimeInterval) -> Int {
        let minutes = max(0, totalSleep / 60)
        let points: Double

        switch minutes {
        case 480...:
            points = 50
        case 450..<480:
            points = 48 + (minutes - 450) / 15
        case 420..<450:
            points = 45 + (minutes - 420) / 10
        case 360..<420:
            points = 35 + (minutes - 360) / 6
        default:
            points = max(0, (minutes - 200) * 35 / 160)
        }

        return Int(min(50, points).rounded(.down))
    }

    static func bedtimePoints(consistency: TimeInterval) -> Int {
        let minutesLater = max(0, consistency / 60)
        let penalty = max(0, minutesLater - 15) / 6
        return Int(max(0, 30 - penalty).rounded())
    }

    static func interruptionPoints(awake: TimeInterval, count: Int) -> Int {
        let awakeMinutes = max(0, awake / 60)
        let durationPenalty = awakeMinutes / 20
        let countPenalty = Double(max(0, count - 4)) * 2
        return Int(max(0, 20 - max(durationPenalty, countPenalty)).rounded(.down))
    }
}
