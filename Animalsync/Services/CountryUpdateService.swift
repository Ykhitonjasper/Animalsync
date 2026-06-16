import Foundation

@Observable
final class CountryUpdateService {
    static let shared = CountryUpdateService()

    private(set) var lastCheckDate: Date?
    private(set) var updateAvailable = false
    private(set) var isChecking = false

    private let bundledVersionKey = "bundledCountryDBVersion"
    private let lastCheckKey = "countryDBLastCheck"

    private init() {
        if let timestamp = UserDefaults.standard.object(forKey: lastCheckKey) as? Date {
            lastCheckDate = timestamp
        }
    }

    func checkForUpdates() async {
        isChecking = true
        defer { isChecking = false }

        try? await Task.sleep(for: .milliseconds(600))

        let bundled = CountryService.shared.globalLastUpdated
        let stored = UserDefaults.standard.string(forKey: bundledVersionKey)

        if stored == nil {
            UserDefaults.standard.set(bundled, forKey: bundledVersionKey)
            updateAvailable = false
        } else if stored != bundled {
            updateAvailable = true
        } else {
            updateAvailable = false
        }

        lastCheckDate = Date()
        UserDefaults.standard.set(lastCheckDate, forKey: lastCheckKey)
    }

    func applyBundledUpdate() {
        CountryService.shared.reload()
        UserDefaults.standard.set(
            CountryService.shared.globalLastUpdated,
            forKey: bundledVersionKey
        )
        updateAvailable = false
    }
}
