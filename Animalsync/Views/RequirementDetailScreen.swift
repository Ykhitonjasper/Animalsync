import SwiftUI
import SwiftData

struct RequirementDetailScreen: View {
    @Bindable var trip: Trip
    let task: TimelineTask
    @Query private var documents: [PetDocument]
    @Environment(\.modelContext) private var context
    @State private var showScanner = false
    @State private var previewDocument: PetDocument?

    private var linkedDocument: PetDocument? {
        guard let idString = trip.requirementDocumentLinks[task.requirementID],
              let uuid = UUID(uuidString: idString) else { return nil }
        return documents.first { $0.id == uuid }
    }

    private var matchingDocuments: [PetDocument] {
        documents.filter { doc in
            doc.petID == trip.petID && doc.category.matches(requirementType: task.type)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                detailSection
                documentSection
                actionsSection
                LegalFootnote()
            }
            .padding()
        }
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showScanner) {
            DocumentScannerScreen(
                presetPetID: trip.petID,
                presetTripID: trip.id,
                presetCategory: task.type.suggestedDocCategory,
                presetTitle: task.title
            )
        }
        .sheet(item: $previewDocument) { doc in
            DocumentPreviewSheet(document: doc)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: task.type.icon)
                    .foregroundStyle(.tint)
                Text(task.type.label)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(task.countryFlag)
            }
            HStack {
                StatusPill(status: task.status)
                Spacer()
                DateOffsetLabel(date: task.deadlineDate, entryDate: trip.entryDate)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "What to do")
            Text(task.descriptionText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var documentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Proof document", subtitle: linkedDocument == nil ? "Not linked" : "Linked")

            if let doc = linkedDocument {
                Button { previewDocument = doc } label: {
                    HStack(spacing: 12) {
                        DocumentThumbnail(document: doc)
                            .frame(width: 100)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(doc.title).font(.subheadline.weight(.semibold))
                            Text(doc.category.label).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)

                Button("Unlink document", role: .destructive) {
                    trip.requirementDocumentLinks.removeValue(forKey: task.requirementID)
                    try? context.save()
                }
                .font(.caption)
            } else if matchingDocuments.isEmpty {
                Text("Scan or import a document that proves this requirement.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(matchingDocuments) { doc in
                    Button {
                        link(doc)
                    } label: {
                        HStack {
                            Image(systemName: doc.category.icon)
                            Text(doc.title)
                                .font(.subheadline)
                            Spacer()
                            Text("Link")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tint)
                        }
                        .padding(10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                showScanner = true
            } label: {
                Label("Scan new document", systemImage: "doc.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "Progress")
            Button {
                toggleCompletion()
            } label: {
                Label(
                    task.isCompleted ? "Mark as not done" : "Mark as done",
                    systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func link(_ document: PetDocument) {
        trip.requirementDocumentLinks[task.requirementID] = document.id.uuidString
        if !trip.completedRequirementIDs.contains(task.requirementID) {
            trip.completedRequirementIDs.append(task.requirementID)
        }
        try? context.save()
    }

    private func toggleCompletion() {
        if let idx = trip.completedRequirementIDs.firstIndex(of: task.requirementID) {
            trip.completedRequirementIDs.remove(at: idx)
        } else {
            trip.completedRequirementIDs.append(task.requirementID)
        }
        try? context.save()
    }
}

private extension DocCategory {
    func matches(requirementType: RequirementType) -> Bool {
        switch requirementType {
        case .rabiesVaccine, .otherVaccine: self == .vaccineRecord
        case .titerTest: self == .titerResult
        case .healthCertificate: self == .healthCertificate
        case .importPermit: self == .importPermit
        case .microchip: self == .microchipReg || self == .passport
        case .parasiteTreatment, .quarantine, .other: self == .other || self == .healthCertificate
        }
    }
}

private extension RequirementType {
    var suggestedDocCategory: DocCategory {
        switch self {
        case .rabiesVaccine, .otherVaccine: .vaccineRecord
        case .titerTest: .titerResult
        case .healthCertificate: .healthCertificate
        case .importPermit: .importPermit
        case .microchip: .microchipReg
        case .parasiteTreatment, .quarantine, .other: .other
        }
    }
}
