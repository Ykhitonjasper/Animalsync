import XCTest
@testable import Animalsync

final class FreemiumGateTests: XCTestCase {
    func testFreePetLimit() {
        let gate = FreemiumGate.shared
        XCTAssertTrue(gate.isPetCreationAllowed(currentCount: 0, isPro: false))
        XCTAssertFalse(gate.isPetCreationAllowed(currentCount: 1, isPro: false))
        XCTAssertTrue(gate.isPetCreationAllowed(currentCount: 5, isPro: true))
    }

    func testFreeTripLimit() {
        let gate = FreemiumGate.shared
        XCTAssertTrue(gate.isTripCreationAllowed(currentActiveCount: 0, isPro: false))
        XCTAssertFalse(gate.isTripCreationAllowed(currentActiveCount: 1, isPro: false))
        XCTAssertTrue(gate.isTripCreationAllowed(currentActiveCount: 3, isPro: true))
    }
}
