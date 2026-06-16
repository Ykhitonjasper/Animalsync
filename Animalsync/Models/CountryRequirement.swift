import Foundation

struct CountryRequirement: Codable, Identifiable, Hashable {
    var id: String { code }
    let code: String
    let name: String
    let flag: String
    let difficulty: Difficulty
    let detailTier: DetailTier
    let requirements: [Requirement]
    let lastUpdated: String
    let officialSource: String
    let notes: String?

    var officialSourceURL: URL? {
        URL(string: officialSource)
    }

    var lastUpdatedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: lastUpdated)
    }

    func requirements(for species: Species) -> [Requirement] {
        requirements.filter { $0.appliesTo(species: species) }
    }
}

struct CountryDatabase: Codable {
    let globalLastUpdated: String
    let countries: [CountryRequirement]
}
