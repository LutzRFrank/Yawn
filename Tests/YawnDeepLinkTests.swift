import Foundation

@main
struct YawnDeepLinkTests {
    static func main() {
        let accepted = [
            "yawnsleep://events/duo-mornings",
            "YAWNSLEEP://EVENTS/duo-mornings"
        ]
        let rejected = [
            "https://events/duo-mornings",
            "yawnsleep://other/duo-mornings",
            "yawnsleep://events/unknown",
            "yawnsleep://events/duo-mornings/extra",
            "yawnsleep://events/duo-mornings/",
            "yawnsleep://events/Duo-Mornings",
            "yawnsleep://events/duo-mornings?score=100",
            "yawnsleep://events/duo-mornings?",
            "yawnsleep://events/duo-mornings#help",
            "yawnsleep://events/duo-mornings#",
            "yawnsleep://user@events/duo-mornings",
            "yawnsleep://user:password@events/duo-mornings",
            "yawnsleep://events:123/duo-mornings",
            "yawnsleep:/events/duo-mornings",
            "yawnsleep://events"
        ]
        for value in accepted {
            let url = URL(string: value)!
            precondition(YawnDeepLink.destination(for: url) == .duoMornings, value)
        }
        for value in rejected {
            let url = URL(string: value)!
            precondition(YawnDeepLink.destination(for: url) == nil, value)
        }
        print("Passed \(accepted.count + rejected.count) deep-link routing checks.")
    }
}
