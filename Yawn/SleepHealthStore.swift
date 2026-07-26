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
        let start = calendar.date(byAdding: .hour, value: -18, to: now) ?? now
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

        var asleep: TimeInterval = 0
        var awake: TimeInterval = 0
        var deep: TimeInterval = 0
        var rem: TimeInterval = 0

        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            guard let value = HKCategoryValueSleepAnalysis(rawValue: sample.value) else { continue }

            switch value {
            case .awake:
                awake += duration
            case .asleepDeep:
                deep += duration
                asleep += duration
            case .asleepREM:
                rem += duration
                asleep += duration
            case .asleepCore, .asleepUnspecified:
                asleep += duration
            default:
                break
            }
        }

        guard asleep > 0 else { throw HealthError.noSleepData }
        return SleepSummary(
            score: SleepScore.calculate(
                totalSleep: asleep,
                awake: awake,
                deep: deep,
                rem: rem
            ),
            totalSleep: asleep,
            awake: awake,
            deep: deep,
            rem: rem
        )
    }
}

enum HealthError: Error {
    case unavailable
    case noSleepData
}
