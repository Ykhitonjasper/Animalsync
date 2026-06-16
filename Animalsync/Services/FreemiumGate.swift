import Foundation

@Observable
final class FreemiumGate {
    static let shared = FreemiumGate()

    var freePetLimit: Int { 1 }
    var freeActiveTripLimit: Int { 1 }

    func isPetCreationAllowed(currentCount: Int, isPro: Bool) -> Bool {
        isPro || currentCount < freePetLimit
    }

    func isTripCreationAllowed(currentActiveCount: Int, isPro: Bool) -> Bool {
        isPro || currentActiveCount < freeActiveTripLimit
    }

    private init() {}
}
