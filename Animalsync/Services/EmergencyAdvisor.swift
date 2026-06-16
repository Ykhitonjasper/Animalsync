import Foundation

enum EmergencyReason: String, CaseIterable, Identifiable {
    case missingRabies
    case expiredTiter
    case wrongPaperwork
    case speciesBanned
    case missingMicrochip
    case quarantineRequired

    var id: String { rawValue }
    var label: String {
        switch self {
        case .missingRabies: "Missing or invalid rabies vaccination"
        case .expiredTiter: "Titer test expired or missing"
        case .wrongPaperwork: "Wrong or missing paperwork"
        case .speciesBanned: "Species not permitted"
        case .missingMicrochip: "Missing microchip"
        case .quarantineRequired: "Mandatory quarantine refused"
        }
    }
    var icon: String {
        switch self {
        case .missingRabies, .expiredTiter: "syringe.fill"
        case .wrongPaperwork: "doc.badge.gearshape.fill"
        case .speciesBanned: "xmark.octagon.fill"
        case .missingMicrochip: "cpu"
        case .quarantineRequired: "house.lodge.fill"
        }
    }
}

struct AlternativeSuggestion: Identifiable, Hashable {
    var id: String { country.code }
    let country: CountryRequirement
    let reasoning: String
    let score: Int
}

enum EmergencyAdvisor {
    static func diagnosis(for reason: EmergencyReason, pet: Pet, destination: CountryRequirement?) -> String {
        switch reason {
        case .missingRabies:
            return "\(pet.name) needs a valid rabies vaccination. Most countries require it administered at least 21 days before entry, with proof on the vaccination certificate."
        case .expiredTiter:
            return "A rabies antibody titer test (FAVN/RFFIT) must show ≥0.5 IU/ml. Results are typically valid for 1–3 years depending on destination."
        case .wrongPaperwork:
            return "Health certificates often require veterinary endorsement within 10 days of travel. Import permits, when required, must be issued before the pet boards."
        case .speciesBanned:
            return "Some destinations restrict species (ferrets, certain breeds, exotic pets). \(destination?.name ?? "This country") may not accept \(pet.species.label.lowercased())s."
        case .missingMicrochip:
            return "An ISO 11784/11785 compliant microchip is required before any rabies vaccination is considered valid for travel."
        case .quarantineRequired:
            return "Strict-rabies countries (AU, NZ, JP, UK from non-listed countries) impose mandatory quarantine. Pre-qualification reduces or eliminates it."
        }
    }

    static func alternatives(for reason: EmergencyReason, pet: Pet, currentDestination: String?) -> [AlternativeSuggestion] {
        let service = CountryService.shared
        let candidates = service.countries.filter { $0.code != currentDestination }

        var scored: [(CountryRequirement, Int, String)] = []
        for c in candidates {
            var score = 0
            var reasons: [String] = []

            switch c.difficulty {
            case .easy: score += 30; reasons.append("Easy entry profile")
            case .moderate: score += 15
            case .hard: score -= 10
            case .restricted: score -= 30
            }

            let petReqs = c.requirements(for: pet.species)
            if !petReqs.isEmpty || c.detailTier != .shallow {
                score += 10
                reasons.append("Accepts \(pet.species.label.lowercased())s")
            } else if c.detailTier == .shallow {
                score -= 5
            }

            switch reason {
            case .speciesBanned:
                if !petReqs.isEmpty || c.detailTier != .shallow {
                    score += 25
                }
            case .missingRabies, .expiredTiter, .missingMicrochip:
                if c.difficulty == .easy || c.difficulty == .moderate {
                    score += 10
                    reasons.append("Lighter vaccination timeline")
                }
            case .wrongPaperwork:
                if c.detailTier == .deep {
                    score += 15
                    reasons.append("Well-documented requirements")
                }
            case .quarantineRequired:
                if c.difficulty != .restricted {
                    score += 20
                    reasons.append("No mandatory quarantine")
                }
            }

            scored.append((c, score, reasons.joined(separator: " · ")))
        }

        return scored
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { AlternativeSuggestion(country: $0.0, reasoning: $0.2, score: $0.1) }
    }
}
