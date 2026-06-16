import Foundation

@Observable
final class CountryService {
    static let shared = CountryService()

    private(set) var countries: [CountryRequirement] = []
    private(set) var globalLastUpdated: String = ""

    private init() {
        load()
    }

    func reload() {
        load()
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            countries = []
            return
        }
        let decoder = JSONDecoder()
        if let db = try? decoder.decode(CountryDatabase.self, from: data) {
            countries = db.countries
            globalLastUpdated = db.globalLastUpdated
        }
    }

    func country(byCode code: String) -> CountryRequirement? {
        countries.first { $0.code == code }
    }

    func countries(byCodes codes: [String]) -> [CountryRequirement] {
        codes.compactMap { country(byCode: $0) }
    }

    func search(_ query: String) -> [CountryRequirement] {
        guard !query.isEmpty else { return countries }
        let lowered = query.lowercased()
        return countries.filter {
            $0.name.lowercased().contains(lowered) || $0.code.lowercased() == lowered
        }
    }
}
