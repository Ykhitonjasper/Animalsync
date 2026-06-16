import SwiftUI
import VisionKit
import SwiftData

struct DocumentScannerScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var pets: [Pet]

    var presetPetID: UUID? = nil
    var presetTripID: UUID? = nil
    var presetCategory: DocCategory = .vaccineRecord
    var presetTitle: String = ""

    @State private var title = ""
    @State private var category: DocCategory = .vaccineRecord
    @State private var selectedPet: Pet?
    @State private var expiresOn = Date().addingTimeInterval(365 * 24 * 3600)
    @State private var hasExpiry = false
    @State private var errorMessage: String?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            #if targetEnvironment(simulator)
            simulatorForm
            #else
            DeviceScannerView(
                onScan: { scan in
                    Task { await saveScan(scan) }
                },
                onCancel: { dismiss() }
            )
            .ignoresSafeArea()
            #endif
        }
        .task {
            category = presetCategory
            if !presetTitle.isEmpty { title = presetTitle }
            if let id = presetPetID {
                selectedPet = pets.first { $0.id == id }
            }
        }
        .alert("Could not save document", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var simulatorForm: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                    Text("Document Scanner")
                        .font(.title2.weight(.semibold))
                    Text("Camera scanning is unavailable in the simulator. Save a placeholder PDF to test the full document flow.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            documentFields
            Section {
                LegalFootnote(compact: true)
            }
        }
        .navigationTitle("Add Document")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await savePlaceholder() }
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
            }
        }
    }

    @ViewBuilder
    private var documentFields: some View {
        Section("Document") {
            TextField("Title", text: $title)
            Picker("Category", selection: $category) {
                ForEach(DocCategory.allCases) { c in
                    Label(c.label, systemImage: c.icon).tag(c)
                }
            }
            Toggle("Expiry date", isOn: $hasExpiry)
            if hasExpiry {
                DatePicker("Expires", selection: $expiresOn, displayedComponents: .date)
            }
        }
        if !pets.isEmpty && presetPetID == nil {
            Section("Linked Pet") {
                Picker("Pet", selection: $selectedPet) {
                    Text("Unassigned").tag(Pet?.none)
                    ForEach(pets) { p in
                        Text("\(p.species.emoji) \(p.name)").tag(Optional(p))
                    }
                }
            }
        }
    }

    @MainActor
    private func savePlaceholder() async {
        isSaving = true
        defer { isSaving = false }
        do {
            let export = try PDFExportService.exportPlaceholderImage()
            insertDocument(from: export)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func saveScan(_ scan: VNDocumentCameraScan) async {
        isSaving = true
        defer { isSaving = false }
        do {
            let export = try PDFExportService.export(scan: scan)
            insertDocument(from: export)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func insertDocument(from export: PDFExportService.ExportResult) {
        let safeTitle = title.trimmingCharacters(in: .whitespaces).isEmpty
            ? "\(category.label) Scan" : title.trimmingCharacters(in: .whitespaces)
        let doc = PetDocument(
            petID: selectedPet?.id ?? presetPetID,
            tripID: presetTripID,
            title: safeTitle,
            category: category,
            pdfFilename: export.pdfFilename,
            thumbnailFilename: export.thumbnailFilename,
            pageCount: export.pageCount,
            expiresOn: hasExpiry ? expiresOn : nil
        )
        context.insert(doc)
        try? context.save()
    }
}

#if !targetEnvironment(simulator)
private struct DeviceScannerView: UIViewControllerRepresentable {
    let onScan: (VNDocumentCameraScan) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan, onCancel: onCancel) }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onScan: (VNDocumentCameraScan) -> Void
        let onCancel: () -> Void

        init(onScan: @escaping (VNDocumentCameraScan) -> Void, onCancel: @escaping () -> Void) {
            self.onScan = onScan
            self.onCancel = onCancel
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                onCancel()
                return
            }
            onScan(scan)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            onCancel()
        }
    }
}
#endif
