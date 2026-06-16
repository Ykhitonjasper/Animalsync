import UIKit

enum MockAssetInstaller {
    struct DocumentSpec {
        let title: String
        let category: DocCategory
        let petName: String
        let species: String
        let breed: String
        let chipNumber: String?
        let lines: [String]
        let pageCount: Int
    }

    static func install(pets: [Pet], documents: [PetDocument]) {
        installAvatars(for: pets)
        installDocuments(documents, pets: pets)
    }

    private static func installAvatars(for pets: [Pet]) {
        for pet in pets {
            guard let baseName = MockData.avatarBundleName(for: pet.id),
                  let bundleURL = Bundle.main.url(forResource: baseName, withExtension: "jpg", subdirectory: "MockAssets")
                    ?? Bundle.main.url(forResource: baseName, withExtension: "jpg"),
                  let image = UIImage(contentsOfFile: bundleURL.path) else { continue }

            if let filename = try? PetAvatarService.save(image: image, petID: pet.id) {
                pet.passportPhotoFilename = filename
            }
        }
    }

    private static func installDocuments(_ documents: [PetDocument], pets: [Pet]) {
        let petByID = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0) })

        for document in documents {
            guard !DocumentStore.fileExists(document.pdfFilename) else { continue }
            guard let petID = document.petID, let pet = petByID[petID] else { continue }

            let spec = spec(for: document, pet: pet)
            if let result = try? generatePDF(spec: spec, pdfFilename: document.pdfFilename) {
                document.thumbnailFilename = result.thumbnailFilename
                document.pageCount = result.pageCount
            }
        }
    }

    private static func spec(for document: PetDocument, pet: Pet) -> DocumentSpec {
        let chip = pet.chipNumber ?? "Not registered"
        let baseLines = [
            "Pet name: \(pet.name)",
            "Species: \(pet.species.label)",
            "Breed: \(pet.breed)",
            "Microchip: \(chip)",
            "Issuing authority: USDA Accredited Veterinarian",
            "Clinic: Westside Animal Hospital, Austin, TX",
            "Document ID: \(document.id.uuidString.prefix(8).uppercased())"
        ]

        let extra: [String]
        switch document.category {
        case .passport:
            extra = [
                "Document type: EU Pet Passport",
                "Owner: James Mitchell",
                "Country of issue: United States",
                "Valid for international travel within approved routes.",
                "Rabies vaccination recorded on page 2.",
                "Tapeworm treatment field available on page 4."
            ]
        case .vaccineRecord:
            extra = document.title.contains("FVRCP")
                ? [
                    "Vaccine: FVRCP (Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia)",
                    "Date administered: May 10, 2025",
                    "Next booster due: May 10, 2026",
                    "Batch number: FVR-2290",
                    "Veterinarian: Dr. Sarah Nguyen, DVM"
                ]
                : [
                    "Vaccine: Rabies",
                    "Date administered: per veterinary record",
                    "Manufacturer batch recorded by issuing clinic.",
                    "Animal declared healthy at time of vaccination.",
                    "Veterinarian signature on file."
                ]
        case .healthCertificate:
            extra = [
                "Certificate type: Official Veterinary Health Certificate",
                "Animal inspected and found free from clinical signs of infectious disease.",
                "Fit to travel by air within 10 days of issue date.",
                "Destination country endorsement pending where required.",
                "Signed: Dr. Emily Hart, DVM — License TX-VET-44821"
            ]
        case .titerResult:
            extra = [
                "Laboratory: Kansas State Rabies Laboratory",
                "Test: FAVN Rabies Antibody Titer Test",
                "Sample collected under veterinary supervision.",
                "Result meets destination country threshold.",
                "Report valid for 24 months from sample date."
            ]
        case .importPermit:
            extra = document.title.contains("Australia")
                ? [
                    "Application status: Under review",
                    "Permit class: Companion animal import",
                    "Quarantine facility pre-approval required.",
                    "Additional blood tests may be requested.",
                    "Contact: Department of Agriculture Import Services"
                ]
                : [
                    "Permit status: Approved",
                    "Import authorization for accompanied pet travel.",
                    "Must be presented with health certificate at border control.",
                    "Single entry valid for scheduled travel window.",
                    "Issued by destination country veterinary authority."
                ]
        case .microchipReg:
            extra = [
                "Registry: PetLink International",
                "ISO microchip standard: 15 digits",
                "Registration status: Active",
                "Owner contact details verified.",
                "24/7 recovery hotline enabled."
            ]
        case .other:
            extra = ["Supporting travel documentation on file."]
        }

        return DocumentSpec(
            title: document.title,
            category: document.category,
            petName: pet.name,
            species: pet.species.label,
            breed: pet.breed,
            chipNumber: pet.chipNumber,
            lines: baseLines + extra,
            pageCount: document.pageCount
        )
    }

    private struct PDFResult {
        let thumbnailFilename: String
        let pageCount: Int
    }

    private static func generatePDF(spec: DocumentSpec, pdfFilename: String) throws -> PDFResult {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let pdfURL = DocumentStore.url(forFilename: pdfFilename)
        let pdfData = NSMutableData()

        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        defer { UIGraphicsEndPDFContext() }

        for pageIndex in 0..<max(spec.pageCount, 1) {
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            drawPage(spec: spec, pageIndex: pageIndex, in: pageRect)
        }

        try pdfData.write(to: pdfURL, options: .atomic)

        let thumbRenderer = UIGraphicsImageRenderer(size: CGSize(width: 612, height: 792))
        let preview = thumbRenderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 612, height: 792))
            drawPage(spec: spec, pageIndex: 0, in: pageRect)
        }

        guard let thumbData = preview.jpegData(compressionQuality: 0.82) else {
            throw InstallError.thumbnailFailed
        }

        let thumbFilename = pdfFilename.replacingOccurrences(of: ".pdf", with: "-thumb.jpg")
        try thumbData.write(to: DocumentStore.url(forFilename: thumbFilename), options: .atomic)

        return PDFResult(thumbnailFilename: thumbFilename, pageCount: spec.pageCount)
    }

    private static func drawPage(spec: DocumentSpec, pageIndex: Int, in rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(rect)

        let headerRect = CGRect(x: 0, y: 0, width: rect.width, height: 96)
        UIColor(red: 0.12, green: 0.38, blue: 0.72, alpha: 1).setFill()
        UIRectFill(headerRect)

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        spec.title.draw(in: CGRect(x: 36, y: 28, width: rect.width - 72, height: 32), withAttributes: titleAttrs)

        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.88)
        ]
        "Animalsync · \(spec.category.label) · Page \(pageIndex + 1) of \(spec.pageCount)".draw(
            in: CGRect(x: 36, y: 60, width: rect.width - 72, height: 20),
            withAttributes: subtitleAttrs
        )

        var y: CGFloat = 120
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]

        for line in spec.lines {
            line.draw(in: CGRect(x: 36, y: y, width: rect.width - 72, height: 22), withAttributes: labelAttrs)
            y += 24
            if y > rect.height - 120 { break }
        }

        if pageIndex == 0 {
            let stampRect = CGRect(x: rect.width - 180, y: rect.height - 130, width: 140, height: 70)
            UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1).setFill()
            UIBezierPath(roundedRect: stampRect, cornerRadius: 8).fill()
            let stampAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: UIColor(red: 0.12, green: 0.38, blue: 0.72, alpha: 1)
            ]
            "VERIFIED COPY\n\(spec.petName.uppercased())".draw(
                in: stampRect.insetBy(dx: 10, dy: 12),
                withAttributes: stampAttrs
            )
        }

        let footer = "Generated for Animalsync demo purposes. Not an official government document."
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        footer.draw(
            in: CGRect(x: 36, y: rect.height - 48, width: rect.width - 72, height: 30),
            withAttributes: footerAttrs
        )
    }

    enum InstallError: Error {
        case thumbnailFailed
    }
}
