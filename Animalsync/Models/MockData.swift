import Foundation

enum MockData {
    static let oliverID = UUID(uuidString: "11111111-0000-0000-0000-000000000001")!
    static let lunaID = UUID(uuidString: "11111111-0000-0000-0000-000000000002")!
    static let cooperID = UUID(uuidString: "11111111-0000-0000-0000-000000000003")!

    static let tripPastID = UUID(uuidString: "22222222-0000-0000-0000-000000000001")!
    static let tripPlanningID = UUID(uuidString: "22222222-0000-0000-0000-000000000002")!
    static let tripReadyID = UUID(uuidString: "22222222-0000-0000-0000-000000000003")!
    static let tripBlockedID = UUID(uuidString: "22222222-0000-0000-0000-000000000004")!

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    static func pets() -> [Pet] {
        [
            Pet(
                id: oliverID,
                name: "Oliver",
                species: .dog,
                breed: "Golden Retriever",
                birthDate: date(2020, 4, 12),
                chipNumber: "985112004567891",
                vaccines: [
                    Vaccine(
                        name: "Rabies (Rabvac 3)",
                        administeredOn: date(2025, 3, 18),
                        validUntil: date(2028, 3, 18),
                        batchNumber: "RBV-2025-0318",
                        notes: "USDA-accredited veterinarian — Dr. Emily Hart"
                    ),
                    Vaccine(
                        name: "DHPP Booster",
                        administeredOn: date(2025, 3, 18),
                        validUntil: date(2026, 3, 18),
                        batchNumber: "DHP-8821"
                    ),
                    Vaccine(
                        name: "Rabies Titer (FAVN)",
                        administeredOn: date(2025, 4, 2),
                        validUntil: date(2027, 4, 2),
                        notes: "Result: 2.8 IU/ml — passed UK threshold"
                    )
                ]
            ),
            Pet(
                id: lunaID,
                name: "Luna",
                species: .cat,
                breed: "Ragdoll",
                birthDate: date(2022, 9, 5),
                chipNumber: "985112009876543",
                vaccines: [
                    Vaccine(
                        name: "Rabies (Purevax)",
                        administeredOn: date(2025, 5, 10),
                        validUntil: date(2026, 5, 10),
                        batchNumber: "PVX-4410",
                        notes: "Administered at Westside Animal Clinic, Austin TX"
                    ),
                    Vaccine(
                        name: "FVRCP",
                        administeredOn: date(2025, 5, 10),
                        validUntil: date(2026, 5, 10),
                        batchNumber: "FVR-2290"
                    )
                ]
            ),
            Pet(
                id: cooperID,
                name: "Cooper",
                species: .dog,
                breed: "Beagle",
                birthDate: date(2019, 11, 28),
                chipNumber: "985112003210987",
                vaccines: [
                    Vaccine(
                        name: "Rabies (Defensor 3)",
                        administeredOn: date(2024, 10, 5),
                        validUntil: date(2027, 10, 5),
                        batchNumber: "DEF-7744"
                    ),
                    Vaccine(
                        name: "DHPP",
                        administeredOn: date(2024, 10, 5),
                        validUntil: date(2025, 10, 5),
                        batchNumber: "DHP-6612"
                    ),
                    Vaccine(
                        name: "Rabies Titer (FAVN)",
                        administeredOn: date(2024, 11, 20),
                        validUntil: date(2026, 11, 20),
                        notes: "Result: 1.6 IU/ml — passed EU threshold"
                    )
                ]
            )
        ]
    }

    static func trips() -> [Trip] {
        [
            Trip(
                id: tripPastID,
                petID: cooperID,
                originCountryCode: "US",
                transitCountryCodes: [],
                destinationCountryCode: "DE",
                entryDate: date(2024, 8, 15),
                status: .past,
                notes: "Berlin relocation completed. All border checks passed at Frankfurt Airport."
            ),
            Trip(
                id: tripPlanningID,
                petID: lunaID,
                originCountryCode: "US",
                transitCountryCodes: ["TR"],
                destinationCountryCode: "AE",
                entryDate: date(2026, 9, 1),
                status: .planning,
                notes: "Dubai residency move. Transit layover in Istanbul — confirm IATA crate specs."
            ),
            Trip(
                id: tripReadyID,
                petID: oliverID,
                originCountryCode: "US",
                transitCountryCodes: ["FR"],
                destinationCountryCode: "GB",
                entryDate: date(2026, 7, 20),
                status: .ready,
                notes: "London assignment. Eurostar pet ticket booked. Tapeworm treatment due 24h before entry."
            ),
            Trip(
                id: tripBlockedID,
                petID: cooperID,
                originCountryCode: "US",
                transitCountryCodes: [],
                destinationCountryCode: "AU",
                entryDate: date(2026, 8, 10),
                status: .blocked,
                notes: "Australia does not permit this entry route without extended quarantine approval."
            )
        ]
    }

    static func documents() -> [PetDocument] {
        [
            // Oliver — 6 documents
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000001")!,
                petID: oliverID,
                tripID: tripReadyID,
                title: "EU Pet Passport",
                category: .passport,
                pdfFilename: "mock-oliver-passport.pdf",
                thumbnailFilename: "mock-oliver-passport-thumb.jpg",
                pageCount: 4,
                expiresOn: date(2028, 3, 18)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000002")!,
                petID: oliverID,
                tripID: tripReadyID,
                title: "Rabies Vaccination Certificate",
                category: .vaccineRecord,
                pdfFilename: "mock-oliver-rabies.pdf",
                thumbnailFilename: "mock-oliver-rabies-thumb.jpg",
                pageCount: 1,
                expiresOn: date(2028, 3, 18)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000003")!,
                petID: oliverID,
                tripID: tripReadyID,
                title: "Rabies Titer Test Report",
                category: .titerResult,
                pdfFilename: "mock-oliver-titer.pdf",
                thumbnailFilename: "mock-oliver-titer-thumb.jpg",
                pageCount: 2,
                expiresOn: date(2027, 4, 2)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000004")!,
                petID: oliverID,
                tripID: tripReadyID,
                title: "Official Health Certificate",
                category: .healthCertificate,
                pdfFilename: "mock-oliver-health.pdf",
                thumbnailFilename: "mock-oliver-health-thumb.jpg",
                pageCount: 2,
                expiresOn: date(2026, 7, 18)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000005")!,
                petID: oliverID,
                title: "Microchip Registration",
                category: .microchipReg,
                pdfFilename: "mock-oliver-microchip.pdf",
                thumbnailFilename: "mock-oliver-microchip-thumb.jpg",
                pageCount: 1
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000006")!,
                petID: oliverID,
                tripID: tripReadyID,
                title: "UK Import Permit",
                category: .importPermit,
                pdfFilename: "mock-oliver-import.pdf",
                thumbnailFilename: "mock-oliver-import-thumb.jpg",
                pageCount: 1,
                expiresOn: date(2026, 12, 31)
            ),

            // Luna — 6 documents
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000011")!,
                petID: lunaID,
                tripID: tripPlanningID,
                title: "EU Pet Passport",
                category: .passport,
                pdfFilename: "mock-luna-passport.pdf",
                thumbnailFilename: "mock-luna-passport-thumb.jpg",
                pageCount: 4,
                expiresOn: date(2026, 5, 10)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000012")!,
                petID: lunaID,
                tripID: tripPlanningID,
                title: "Rabies Vaccination Certificate",
                category: .vaccineRecord,
                pdfFilename: "mock-luna-rabies.pdf",
                thumbnailFilename: "mock-luna-rabies-thumb.jpg",
                pageCount: 1,
                expiresOn: date(2026, 5, 10)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000013")!,
                petID: lunaID,
                title: "FVRCP Vaccination Record",
                category: .vaccineRecord,
                pdfFilename: "mock-luna-fvrcp.pdf",
                thumbnailFilename: "mock-luna-fvrcp-thumb.jpg",
                pageCount: 1,
                expiresOn: date(2026, 5, 10)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000014")!,
                petID: lunaID,
                tripID: tripPlanningID,
                title: "Veterinary Health Certificate",
                category: .healthCertificate,
                pdfFilename: "mock-luna-health.pdf",
                thumbnailFilename: "mock-luna-health-thumb.jpg",
                pageCount: 2,
                expiresOn: date(2026, 8, 25)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000015")!,
                petID: lunaID,
                title: "Microchip Registration",
                category: .microchipReg,
                pdfFilename: "mock-luna-microchip.pdf",
                thumbnailFilename: "mock-luna-microchip-thumb.jpg",
                pageCount: 1
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000016")!,
                petID: lunaID,
                tripID: tripPlanningID,
                title: "UAE Import Permit",
                category: .importPermit,
                pdfFilename: "mock-luna-import.pdf",
                thumbnailFilename: "mock-luna-import-thumb.jpg",
                pageCount: 2,
                expiresOn: date(2026, 9, 30)
            ),

            // Cooper — 6 documents
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000021")!,
                petID: cooperID,
                tripID: tripPastID,
                title: "EU Pet Passport",
                category: .passport,
                pdfFilename: "mock-cooper-passport.pdf",
                thumbnailFilename: "mock-cooper-passport-thumb.jpg",
                pageCount: 4,
                expiresOn: date(2027, 10, 5)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000022")!,
                petID: cooperID,
                title: "Rabies Vaccination Certificate",
                category: .vaccineRecord,
                pdfFilename: "mock-cooper-rabies.pdf",
                thumbnailFilename: "mock-cooper-rabies-thumb.jpg",
                pageCount: 1,
                expiresOn: date(2027, 10, 5)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000023")!,
                petID: cooperID,
                tripID: tripPastID,
                title: "Rabies Titer Test Report",
                category: .titerResult,
                pdfFilename: "mock-cooper-titer.pdf",
                thumbnailFilename: "mock-cooper-titer-thumb.jpg",
                pageCount: 2,
                expiresOn: date(2026, 11, 20)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000024")!,
                petID: cooperID,
                tripID: tripPastID,
                title: "Official Health Certificate",
                category: .healthCertificate,
                pdfFilename: "mock-cooper-health.pdf",
                thumbnailFilename: "mock-cooper-health-thumb.jpg",
                pageCount: 2,
                expiresOn: date(2024, 8, 10)
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000025")!,
                petID: cooperID,
                title: "Microchip Registration",
                category: .microchipReg,
                pdfFilename: "mock-cooper-microchip.pdf",
                thumbnailFilename: "mock-cooper-microchip-thumb.jpg",
                pageCount: 1
            ),
            PetDocument(
                id: UUID(uuidString: "33333333-0000-0000-0000-000000000026")!,
                petID: cooperID,
                tripID: tripBlockedID,
                title: "Australia Import Application",
                category: .importPermit,
                pdfFilename: "mock-cooper-import.pdf",
                thumbnailFilename: "mock-cooper-import-thumb.jpg",
                pageCount: 3,
                expiresOn: date(2026, 8, 1)
            )
        ]
    }

    static func avatarBundleName(for petID: UUID) -> String? {
        switch petID {
        case oliverID: "mock-oliver"
        case lunaID: "mock-luna"
        case cooperID: "mock-cooper"
        default: nil
        }
    }
}
