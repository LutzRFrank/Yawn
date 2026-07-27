import Foundation
import WatchConnectivity

@MainActor
final class PhoneScoreStore: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneScoreStore()

    @Published private(set) var score: Int?

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        apply(session.receivedApplicationContext)
    }

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        applyOnMainActor(session.receivedApplicationContext)
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        applyOnMainActor(applicationContext)
    }

    nonisolated private func applyOnMainActor(_ context: [String: Any]) {
        Task { @MainActor in
            apply(context)
        }
    }

    private func apply(_ context: [String: Any]) {
        guard let score = context["score"] as? Int,
              let timestamp = context["day"] as? TimeInterval else {
            return
        }

        let sentDay = Date(timeIntervalSince1970: timestamp)
        guard Calendar.current.isDate(sentDay, inSameDayAs: .now) else {
            return
        }
        self.score = score
    }
}
