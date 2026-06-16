import SwiftUI
import SwiftData

struct DocumentsScreen: View {
    @Query(sort: \PetDocument.createdAt, order: .reverse) private var documents: [PetDocument]
    @State private var showScanner = false
    @State private var selectedDoc: PetDocument?

    private var grouped: [(DocCategory, [PetDocument])] {
        DocCategory.allCases.compactMap { cat in
            let docs = documents.filter { $0.category == cat }
            return docs.isEmpty ? nil : (cat, docs)
        }
    }

    var body: some View {
        Group {
            if documents.isEmpty {
                EmptyStateView(
                    icon: "doc.text.fill",
                    title: "No documents yet",
                    message: "Scan vet passports, vaccine cards, and health certificates. Everything stays on your device.",
                    actionTitle: "Scan Document"
                ) { showScanner = true }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        AppNavigationTitle(
                            title: "Documents",
                            subtitle: "Scanned passports, certificates, and proof",
                            badge: "\(documents.count)",
                            action: { showScanner = true },
                            actionLabel: "Scan Document"
                        )

                        ForEach(grouped, id: \.0) { (cat, docs) in
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: cat.label, subtitle: "\(docs.count) item\(docs.count == 1 ? "" : "s")")
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                    ForEach(docs) { doc in
                                        Button { selectedDoc = doc } label: {
                                            DocumentThumbnail(document: doc)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        LegalFootnote()
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.bottom, AppTheme.spacingLG)
                }
            }
        }
        .appScreen()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showScanner) {
            DocumentScannerScreen()
        }
        .sheet(item: $selectedDoc) { doc in
            DocumentPreviewSheet(document: doc)
        }
    }
}
