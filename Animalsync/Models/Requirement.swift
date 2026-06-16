import Foundation

struct Requirement: Codable, Identifiable, Hashable {
    let stableID: String
    let typeRaw: String
    let title: String
    let descriptionText: String
    let daysBeforeEntryMin: Int
    let daysBeforeEntryMax: Int
    let required: Bool
    let appliesToSpecies: [String]

    var id: String { stableID }
    var type: RequirementType { RequirementType(rawValue: typeRaw) ?? .other }

    func appliesTo(species: Species) -> Bool {
        appliesToSpecies.isEmpty || appliesToSpecies.contains(species.rawValue)
    }
}
