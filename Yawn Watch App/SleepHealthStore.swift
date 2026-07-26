import Foundation
import HealthKit

actor SleepHealthStore {
    static let shared = SleepHealthStore()
    private let store = HKHealthStore()

    func latestNight(now: Date = .now) async throws -> SleepSummary {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthError.unavailable
        }
        try await store.requestAuthorization(toShare: [], read: [type])
        let start = Calendar.current.date(byAdding: .hour, value: -18, to: now) ?? now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictEndDate)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.categorySample(type: type, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\.startDate)]
        )

        var total: TimeInterval = 0
        var awake: TimeInterval = 0
        var deep: TimeInterval = 0
        var rem: TimeInterval = 0

        for sample in try await descriptor.result(for: store) {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            guard let value = HKCategoryValueSleepAnalysis(rawValue: sample.value) else { continue }
            switch value {
            case .awake: awake += duration
            case .asleepDeep: deep += duration; total += duration
            case .asleepREM: rem += duration; total += duration
            case .asleepCore, .asleepUnspecified: total += duration
            default: break
            }
        }
        guard total > 0 else { throw HealthError.noData }
        return SleepScore.summary(total: total, awake: awake, deep: deep, rem: rem)
    }
}

enum HealthError: Error {
    case unavailable, noData
}
