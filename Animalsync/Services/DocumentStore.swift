import Foundation

enum DocumentStore {
    static var directoryURL: URL {
        let fm = FileManager.default
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("PetDocuments", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func url(forFilename name: String) -> URL {
        directoryURL.appendingPathComponent(name)
    }

    static func fileExists(_ name: String) -> Bool {
        FileManager.default.fileExists(atPath: url(forFilename: name).path)
    }

    static func deleteFile(_ name: String) {
        let path = url(forFilename: name)
        try? FileManager.default.removeItem(at: path)
    }

    static func thumbnailURL(for document: PetDocument) -> URL? {
        guard let name = document.thumbnailFilename else { return nil }
        return url(forFilename: name)
    }
}
