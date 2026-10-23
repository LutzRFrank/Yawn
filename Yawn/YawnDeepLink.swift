import Foundation

enum YawnDeepLink: Equatable {
    case duoMornings

    static func destination(for url: URL) -> Self? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "yawnsleep",
              components.host?.lowercased() == "events",
              components.path == "/duo-mornings",
              components.user == nil,
              components.password == nil,
              components.port == nil,
              components.query == nil,
              components.fragment == nil else {
            return nil
        }
        return .duoMornings
    }
}
