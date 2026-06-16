import Foundation
import SwiftData

@Model
final class Trip {
    @Attribute(.unique) var id: UUID
    var petID: UUID
    var originCountryCode: String
    var transitCountryCodes: [String]
    var destinationCountryCode: String
    var entryDate: Date
    var statusRaw: String
    var createdAt: Date
    var notes: String?
    var completedRequirementIDs: [String]
    var requirementDocumentLinks: [String: String]

    var status: TripStatus {
        get { TripStatus(rawValue: statusRaw) ?? .planning }
        set { statusRaw = newValue.rawValue }
    }

    var daysUntilEntry: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: entryDate).day ?? 0
    }

    init(id: UUID = UUID(),
         petID: UUID,
         originCountryCode: String,
         transitCountryCodes: [String] = [],
         destinationCountryCode: String,
         entryDate: Date,
         status: TripStatus = .planning,
         notes: String? = nil,
         completedRequirementIDs: [String] = [],
         requirementDocumentLinks: [String: String] = [:]) {
        self.id = id
        self.petID = petID
        self.originCountryCode = originCountryCode
        self.transitCountryCodes = transitCountryCodes
        self.destinationCountryCode = destinationCountryCode
        self.entryDate = entryDate
        self.statusRaw = status.rawValue
        self.createdAt = Date()
        self.notes = notes
        self.completedRequirementIDs = completedRequirementIDs
        self.requirementDocumentLinks = requirementDocumentLinks
    }
}
