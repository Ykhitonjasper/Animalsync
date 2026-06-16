import XCTest
@testable import Animalsync

final class TimelineEngineTests: XCTestCase {
    func testTasksGeneratedForUSDestination() {
        let pet = Pet(name: "Luna", species: .dog, breed: "Beagle", birthDate: Date())
        let trip = Trip(
            petID: pet.id,
            originCountryCode: "RU",
            destinationCountryCode: "US",
            entryDate: Date().addingTimeInterval(120 * 24 * 3600)
        )

        let tasks = TimelineEngine.tasks(for: trip, pet: pet)
        XCTAssertFalse(tasks.isEmpty)
        XCTAssertTrue(tasks.contains { $0.requirementID == "US-RABIES" })
        XCTAssertTrue(tasks.allSatisfy { $0.deadlineDate <= trip.entryDate })
    }

    func testCompletedRequirementMarkedDone() {
        let pet = Pet(name: "Milo", species: .cat, breed: "Tabby", birthDate: Date())
        var trip = Trip(
            petID: pet.id,
            originCountryCode: "DE",
            destinationCountryCode: "GB",
            entryDate: Date().addingTimeInterval(60 * 24 * 3600),
            completedRequirementIDs: ["GB-RABIES"]
        )

        let tasks = TimelineEngine.tasks(for: trip, pet: pet)
        let rabies = tasks.first { $0.requirementID == "GB-RABIES" }
        XCTAssertEqual(rabies?.status, .done)
        XCTAssertTrue(rabies?.isCompleted == true)
    }

    func testLinkedDocumentPropagatesToTask() {
        let docID = UUID()
        let pet = Pet(name: "Rex", species: .dog, breed: "Lab", birthDate: Date())
        let trip = Trip(
            petID: pet.id,
            originCountryCode: "US",
            destinationCountryCode: "GB",
            entryDate: Date().addingTimeInterval(90 * 24 * 3600),
            requirementDocumentLinks: ["GB-RABIES": docID.uuidString]
        )

        let tasks = TimelineEngine.tasks(for: trip, pet: pet)
        let rabies = tasks.first { $0.requirementID == "GB-RABIES" }
        XCTAssertEqual(rabies?.linkedDocumentID, docID)
    }

    func testTransitCountriesIncluded() {
        let pet = Pet(name: "Kira", species: .dog, breed: "Husky", birthDate: Date())
        let trip = Trip(
            petID: pet.id,
            originCountryCode: "RU",
            transitCountryCodes: ["DE"],
            destinationCountryCode: "GB",
            entryDate: Date().addingTimeInterval(100 * 24 * 3600)
        )

        let tasks = TimelineEngine.tasks(for: trip, pet: pet)
        let codes = Set(tasks.map(\.countryCode))
        XCTAssertTrue(codes.contains("DE"))
        XCTAssertTrue(codes.contains("GB"))
    }
}
