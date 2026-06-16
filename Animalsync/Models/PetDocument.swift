import Foundation
import SwiftData

@Model
final class PetDocument {
    @Attribute(.unique) var id: UUID
    var petID: UUID?
    var tripID: UUID?
    var title: String
    var categoryRaw: String
    var pdfFilename: String
    var thumbnailFilename: String?
    var pageCount: Int
    var createdAt: Date
    var expiresOn: Date?

    var category: DocCategory {
        get { DocCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var isExpired: Bool {
        guard let expiresOn else { return false }
        return expiresOn < Date()
    }

    init(id: UUID = UUID(),
         petID: UUID? = nil,
         tripID: UUID? = nil,
         title: String,
         category: DocCategory,
         pdfFilename: String,
         thumbnailFilename: String? = nil,
         pageCount: Int = 1,
         expiresOn: Date? = nil) {
        self.id = id
        self.petID = petID
        self.tripID = tripID
        self.title = title
        self.categoryRaw = category.rawValue
        self.pdfFilename = pdfFilename
        self.thumbnailFilename = thumbnailFilename
        self.pageCount = pageCount
        self.createdAt = Date()
        self.expiresOn = expiresOn
    }
}
