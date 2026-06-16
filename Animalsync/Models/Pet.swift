import Foundation
import SwiftData

@Model
final class Pet {
    @Attribute(.unique) var id: UUID
    var name: String
    var speciesRaw: String
    var breed: String
    var birthDate: Date
    var chipNumber: String?
    var passportPhotoFilename: String?
    var vaccines: [Vaccine]
    var createdAt: Date

    var species: Species {
        get { Species(rawValue: speciesRaw) ?? .other }
        set { speciesRaw = newValue.rawValue }
    }

    var ageYears: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    init(id: UUID = UUID(),
         name: String,
         species: Species,
         breed: String,
         birthDate: Date,
         chipNumber: String? = nil,
         passportPhotoFilename: String? = nil,
         vaccines: [Vaccine] = []) {
        self.id = id
        self.name = name
        self.speciesRaw = species.rawValue
        self.breed = breed
        self.birthDate = birthDate
        self.chipNumber = chipNumber
        self.passportPhotoFilename = passportPhotoFilename
        self.vaccines = vaccines
        self.createdAt = Date()
    }
}
