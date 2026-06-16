import UIKit

enum PetAvatarService {
    static var directoryURL: URL {
        let fm = FileManager.default
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("PetAvatars", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func url(forFilename filename: String) -> URL {
        directoryURL.appendingPathComponent(filename)
    }

    static func image(for filename: String?) -> UIImage? {
        guard let filename else { return nil }
        let path = url(forFilename: filename).path
        return UIImage(contentsOfFile: path)
    }

    @discardableResult
    static func save(image: UIImage, petID: UUID, existingFilename: String? = nil) throws -> String {
        if let existingFilename {
            delete(filename: existingFilename)
        }

        let side: CGFloat = 480
        let square = image.croppedToSquare(side: side)
        guard let data = square.jpegData(compressionQuality: 0.88) else {
            throw AvatarError.encodingFailed
        }

        let filename = "avatar-\(petID.uuidString).jpg"
        try data.write(to: url(forFilename: filename), options: .atomic)
        return filename
    }

    static func delete(filename: String?) {
        guard let filename else { return }
        try? FileManager.default.removeItem(at: url(forFilename: filename))
    }

    enum AvatarError: LocalizedError {
        case encodingFailed

        var errorDescription: String? {
            "Could not save the pet photo."
        }
    }
}

private extension UIImage {
    func croppedToSquare(side: CGFloat) -> UIImage {
        let shortest = min(size.width, size.height)
        let originX = (size.width - shortest) / 2
        let originY = (size.height - shortest) / 2
        let cropRect = CGRect(x: originX * scale, y: originY * scale, width: shortest * scale, height: shortest * scale)

        guard let cgImage, let cropped = cgImage.cropping(to: cropRect) else { return self }
        let croppedImage = UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: CGSize(width: side, height: side)))
        }
    }
}
