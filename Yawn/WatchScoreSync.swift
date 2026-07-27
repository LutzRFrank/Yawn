import Foundation
import WatchConnectivity

final class WatchScoreSync: NSObject, WCSessionDelegate {
    static let shared = WatchScoreSync()

    private var pendingContext: [String: Any]?

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func send(score: Int, now: Date = .now) {
        guard WCSession.isSupported() else { return }
        pendingContext = [
            "score": score,
            "day": Calendar.current.startOfDay(for: now).timeIntervalSince1970
        ]
        WCSession.default.activate()
        sendPendingContext()
    }

    private func sendPendingContext() {
        guard WCSession.default.activationState == .activated,
              let pendingContext else { return }
        try? WCSession.default.updateApplicationContext(pendingContext)
        self.pendingContext = nil
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        sendPendingContext()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}
