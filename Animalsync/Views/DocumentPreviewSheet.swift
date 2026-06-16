import SwiftUI
import SwiftData

struct DocumentPreviewSheet: View {
    let document: PetDocument
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var pets: [Pet]
    @State private var showDeleteConfirm = false

    private var pet: Pet? {
        guard let id = document.petID else { return nil }
        return pets.first { $0.id == id }
    }

    private var pdfURL: URL {
        DocumentStore.url(forFilename: document.pdfFilename)
    }

    private var fileExists: Bool {
        DocumentStore.fileExists(document.pdfFilename)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if fileExists {
                        DocumentPDFView(url: pdfURL)
                            .frame(minHeight: 420)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)
                    } else {
                        missingFilePlaceholder
                    }

                    metadataCard

                    if fileExists {
                        ShareLink(item: pdfURL) {
                            Label("Share PDF", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal)
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Document", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)

                    LegalFootnote()
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Delete this document?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive, action: deleteDocument)
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var missingFilePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14).fill(.tint.opacity(0.12))
            VStack(spacing: 12) {
                Image(systemName: document.category.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                Text("PDF file not found on device")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 280)
        .padding(.horizontal)
    }

    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRow(label: "Title", value: document.title)
            InfoRow(label: "Category", value: document.category.label)
            if let pet {
                InfoRow(label: "Pet", value: "\(pet.species.emoji) \(pet.name)")
            }
            InfoRow(label: "Pages", value: "\(document.pageCount)")
            InfoRow(label: "Added", value: document.createdAt.formatted(date: .long, time: .omitted))
            if let expires = document.expiresOn {
                InfoRow(
                    label: "Expires",
                    value: expires.formatted(date: .long, time: .omitted),
                    valueColor: document.isExpired ? .red : .primary
                )
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func deleteDocument() {
        DocumentStore.deleteFile(document.pdfFilename)
        if let thumb = document.thumbnailFilename {
            DocumentStore.deleteFile(thumb)
        }
        context.delete(document)
        try? context.save()
        dismiss()
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.medium)).foregroundStyle(valueColor)
        }
    }
}
