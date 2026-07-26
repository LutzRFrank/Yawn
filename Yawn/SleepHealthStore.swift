import Foundation
import HealthKit

actor SleepHealthStore {
    static let shared = SleepHealthStore()

    private let store = HKHealthStore()

    func latestNight(now: Date = .now) async throws -> SleepSummary {
        guard HKHealthStore.isHealthDataAvailable(),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthError.unavailable
        }

        try await store.requestAuthorization(toShare: [], read: [sleepType])

        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: now,
            options: .strictEndDate
        )
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: sleepType, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )
        let samples = try await descriptor.result(for: store)

        var asleepIntervals: [DateInterval] = []
        var awakeIntervals: [DateInterval] = []

        for sample in samples {
            let interval = DateInterval(start: sample.startDate, end: sample.endDate)
            guard interval.duration > 0 else { continue }
            guard let value = HKCategoryValueSleepAnalysis(rawValue: sample.value) else { continue }

            switch value {
            case .awake:
                awakeIntervals.append(interval)
            case .asleepCore, .asleepDeep, .asleepREM, .asleepUnspecified:
                asleepIntervals.append(interval)
            default:
                break
            }
        }

        let nights = asleepIntervals
            .merged()
            .groupedIntoSleepSessions()
            .filter { $0.totalSleep >= 2 * 3600 }
        guard let latestNight = nights.last else {
            throw HealthError.noSleepData
        }

        let bedtime = latestNight.start
        let sleepWindow = DateInterval(start: bedtime, end: latestNight.end)
        let interruptions = awakeIntervals
            .compactMap { $0.intersection(with: sleepWindow) }
            .merged()
        let totalSleep = latestNight.totalSleep
        let awake = interruptions.reduce(0) { $0 + $1.duration }
        let interruptionCount = interruptions.count { $0.duration >= 2 * 60 }
        let bedtimeConsistency = nights.suffix(13).bedtimeConsistency()

        return SleepSummary(
            score: SleepScore.calculate(
                totalSleep: totalSleep,
                bedtimeConsistency: bedtimeConsistency,
                awake: awake,
                interruptionCount: interruptionCount
            ),
            totalSleep: totalSleep,
            bedtime: bedtime,
            bedtimeConsistency: bedtimeConsistency,
            awake: awake,
            interruptionCount: interruptionCount
        )
    }
}

private struct SleepSession {
    let intervals: [DateInterval]

    var start: Date { intervals[0].start }
    var end: Date { intervals[intervals.count - 1].end }
    var totalSleep: TimeInterval { intervals.reduce(0) { $0 + $1.duration } }
}

private extension Array where Element == DateInterval {
    func merged() -> [DateInterval] {
        sorted { $0.start < $1.start }.reduce(into: []) { result, interval in
            guard let last = result.last else {
                result.append(interval)
                return
            }

            if interval.start <= last.end {
                result[result.count - 1] = DateInterval(
                    start: last.start,
                    end: Swift.max(last.end, interval.end)
                )
            } else {
                result.append(interval)
            }
        }
    }

    func groupedIntoSleepSessions(maximumGap: TimeInterval = 3 * 3600) -> [SleepSession] {
        reduce(into: []) { sessions, interval in
            guard let lastSession = sessions.last,
                  let lastInterval = lastSession.intervals.last,
                  interval.start.timeIntervalSince(lastInterval.end) <= maximumGap else {
                sessions.append(SleepSession(intervals: [interval]))
                return
            }

            sessions[sessions.count - 1] = SleepSession(
                intervals: lastSession.intervals + [interval]
            )
        }
    }
}

private extension Collection where Element == SleepSession {
    func bedtimeConsistency(calendar: Calendar = .current) -> TimeInterval {
        let bedtimeMinutes = map { session -> Double in
            let components = calendar.dateComponents([.hour, .minute], from: session.start)
            return Double((components.hour ?? 0) * 60 + (components.minute ?? 0))
        }
        guard bedtimeMinutes.count > 1 else { return 0 }

        let angles = bedtimeMinutes.map { $0 / (24 * 60) * 2 * Double.pi }
        let meanAngle = atan2(
            angles.reduce(0) { $0 + sin($1) },
            angles.reduce(0) { $0 + cos($1) }
        )
        let meanMinutes = (meanAngle >= 0 ? meanAngle : meanAngle + 2 * .pi)
            / (2 * .pi) * 24 * 60
        let averageDeviation = bedtimeMinutes.reduce(0) { result, minutes in
            let direct = abs(minutes - meanMinutes)
            return result + Swift.min(direct, 24 * 60 - direct)
        } / Double(bedtimeMinutes.count)
        return averageDeviation * 60
    }
}

enum HealthError: Error {
    case unavailable
    case noSleepData
}
