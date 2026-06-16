import XCTest
@testable import Animalsync

final class CountryServiceTests: XCTestCase {
    func testCountriesLoadedFromBundle() {
        let service = CountryService.shared
        XCTAssertGreaterThan(service.countries.count, 30)
        XCTAssertFalse(service.globalLastUpdated.isEmpty)
    }

    func testSearchByName() {
        let service = CountryService.shared
        let results = service.search("germany")
        XCTAssertTrue(results.contains { $0.code == "DE" })
    }

    func testCountryByCode() {
        let service = CountryService.shared
        let us = service.country(byCode: "US")
        XCTAssertNotNil(us)
        XCTAssertEqual(us?.name, "United States")
        XCTAssertFalse(us?.requirements(for: .dog).isEmpty ?? true)
    }

    func testReloadRefreshesData() {
        let service = CountryService.shared
        let before = service.countries.count
        service.reload()
        XCTAssertEqual(service.countries.count, before)
    }
}
