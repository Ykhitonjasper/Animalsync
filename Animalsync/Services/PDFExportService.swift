import UIKit
import VisionKit

enum PDFExportService {
    struct ExportResult {
        let pdfFilename: String
        let thumbnailFilename: String?
        let pageCount: Int
    }

    static func export(scan: VNDocumentCameraScan) throws -> ExportResult {
        let pageCount = scan.pageCount
        guard pageCount > 0 else {
            throw ExportError.emptyScan
        }

        let pdfFilename = "scan-\(UUID().uuidString).pdf"
        let pdfURL = DocumentStore.url(forFilename: pdfFilename)

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        defer { UIGraphicsEndPDFContext() }

        for index in 0..<pageCount {
            let image = scan.imageOfPage(at: index)
            let pageRect = CGRect(origin: .zero, size: image.size)
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            image.draw(in: pageRect)
        }

        try pdfData.write(to: pdfURL, options: .atomic)

        let thumbnailFilename = try saveThumbnail(from: scan.imageOfPage(at: 0))

        return ExportResult(
            pdfFilename: pdfFilename,
            thumbnailFilename: thumbnailFilename,
            pageCount: pageCount
        )
    }

    static func exportPlaceholderImage() throws -> ExportResult {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 612, height: 792))
        let image = renderer.image { ctx in
            UIColor.systemBackground.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 612, height: 792))
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let text = "Animalsync Document"
            let size = text.size(withAttributes: attrs)
            let origin = CGPoint(x: (612 - size.width) / 2, y: (792 - size.height) / 2)
            text.draw(at: origin, withAttributes: attrs)
        }

        let pdfFilename = "stub-\(UUID().uuidString).pdf"
        let pdfURL = DocumentStore.url(forFilename: pdfFilename)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil)
        image.draw(in: CGRect(x: 0, y: 0, width: 612, height: 792))
        UIGraphicsEndPDFContext()
        try pdfData.write(to: pdfURL, options: .atomic)

        let thumbnailFilename = try saveThumbnail(from: image)
        return ExportResult(pdfFilename: pdfFilename, thumbnailFilename: thumbnailFilename, pageCount: 1)
    }

    private static func saveThumbnail(from image: UIImage) throws -> String {
        let maxSide: CGFloat = 240
        let scale = min(maxSide / image.size.width, maxSide / image.size.height, 1)
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let thumb = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        guard let data = thumb.jpegData(compressionQuality: 0.82) else {
            throw ExportError.thumbnailFailed
        }
        let filename = "thumb-\(UUID().uuidString).jpg"
        try data.write(to: DocumentStore.url(forFilename: filename), options: .atomic)
        return filename
    }

    enum ExportError: LocalizedError {
        case emptyScan
        case thumbnailFailed

        var errorDescription: String? {
            switch self {
            case .emptyScan: "No pages were captured."
            case .thumbnailFailed: "Could not create document thumbnail."
            }
        }
    }
}
