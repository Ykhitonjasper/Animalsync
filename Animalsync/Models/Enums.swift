import Foundation
import SwiftUI

enum Species: String, Codable, CaseIterable, Identifiable {
    case dog, cat, ferret, rabbit, bird, reptile, other
    var id: String { rawValue }
    var emoji: String {
        switch self {
        case .dog: "🐕"
        case .cat: "🐈"
        case .ferret: "🦦"
        case .rabbit: "🐇"
        case .bird: "🦜"
        case .reptile: "🦎"
        case .other: "🐾"
        }
    }
    var label: String {
        switch self {
        case .dog: "Dog"
        case .cat: "Cat"
        case .ferret: "Ferret"
        case .rabbit: "Rabbit"
        case .bird: "Bird"
        case .reptile: "Reptile"
        case .other: "Other"
        }
    }
}

enum TripStatus: String, Codable, CaseIterable {
    case past, planning, ready, blocked
    var label: String {
        switch self {
        case .past: "Completed"
        case .planning: "Planning"
        case .ready: "Ready to Go"
        case .blocked: "Blocked"
        }
    }
    var tint: Color {
        switch self {
        case .past: .secondary
        case .planning: .orange
        case .ready: .green
        case .blocked: .red
        }
    }
    var systemImage: String {
        switch self {
        case .past: "checkmark.circle.fill"
        case .planning: "calendar.badge.clock"
        case .ready: "airplane.departure"
        case .blocked: "exclamationmark.octagon.fill"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy, moderate, hard, restricted
    var label: String { rawValue.capitalized }
    var tint: Color {
        switch self {
        case .easy: .green
        case .moderate: .yellow
        case .hard: .orange
        case .restricted: .red
        }
    }
}

enum DetailTier: String, Codable {
    case deep, medium, shallow
}

enum RequirementType: String, Codable, CaseIterable {
    case rabiesVaccine
    case otherVaccine
    case titerTest
    case parasiteTreatment
    case microchip
    case healthCertificate
    case importPermit
    case quarantine
    case other

    var icon: String {
        switch self {
        case .rabiesVaccine, .otherVaccine: "syringe.fill"
        case .titerTest: "testtube.2"
        case .parasiteTreatment: "pills.fill"
        case .microchip: "cpu"
        case .healthCertificate: "doc.text.fill"
        case .importPermit: "checkmark.seal.fill"
        case .quarantine: "house.lodge.fill"
        case .other: "questionmark.circle"
        }
    }
    var label: String {
        switch self {
        case .rabiesVaccine: "Rabies Vaccination"
        case .otherVaccine: "Other Vaccination"
        case .titerTest: "Titer Test"
        case .parasiteTreatment: "Parasite Treatment"
        case .microchip: "Microchip"
        case .healthCertificate: "Health Certificate"
        case .importPermit: "Import Permit"
        case .quarantine: "Quarantine"
        case .other: "Other Requirement"
        }
    }
}

enum DocCategory: String, Codable, CaseIterable, Identifiable {
    case passport, vaccineRecord, healthCertificate, titerResult, importPermit, microchipReg, other
    var id: String { rawValue }
    var label: String {
        switch self {
        case .passport: "Passport"
        case .vaccineRecord: "Vaccine Record"
        case .healthCertificate: "Health Certificate"
        case .titerResult: "Titer Test"
        case .importPermit: "Import Permit"
        case .microchipReg: "Microchip Registration"
        case .other: "Other"
        }
    }
    var icon: String {
        switch self {
        case .passport: "book.closed.fill"
        case .vaccineRecord: "syringe.fill"
        case .healthCertificate: "cross.case.fill"
        case .titerResult: "testtube.2"
        case .importPermit: "checkmark.seal.fill"
        case .microchipReg: "cpu"
        case .other: "doc.fill"
        }
    }
}

enum TaskStatus: String, Codable {
    case done, scheduled, dueSoon, overdue, locked
    var label: String {
        switch self {
        case .done: "Done"
        case .scheduled: "Scheduled"
        case .dueSoon: "Due Soon"
        case .overdue: "Overdue"
        case .locked: "Pro Feature"
        }
    }
    var tint: Color {
        switch self {
        case .done: .green
        case .scheduled: .blue
        case .dueSoon: .orange
        case .overdue: .red
        case .locked: .secondary
        }
    }
    var icon: String {
        switch self {
        case .done: "checkmark.circle.fill"
        case .scheduled: "calendar"
        case .dueSoon: "clock.fill"
        case .overdue: "exclamationmark.triangle.fill"
        case .locked: "lock.fill"
        }
    }
}
