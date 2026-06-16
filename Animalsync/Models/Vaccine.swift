import Foundation

struct Vaccine: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var administeredOn: Date
    var validUntil: Date?
    var batchNumber: String?
    var notes: String?

    init(id: UUID = UUID(), name: String, administeredOn: Date,
         validUntil: Date? = nil, batchNumber: String? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.administeredOn = administeredOn
        self.validUntil = validUntil
        self.batchNumber = batchNumber
        self.notes = notes
    }
}
