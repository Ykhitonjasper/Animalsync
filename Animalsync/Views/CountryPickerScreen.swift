import SwiftUI

struct CountryPickerScreen: View {
    let title: String
    let initialSelection: [String]
    let multiSelect: Bool
    var onConfirm: ([String]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selection: Set<String> = []

    private var filtered: [CountryRequirement] {
        CountryService.shared.search(query)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        LastUpdatedLabel(dateString: CountryService.shared.globalLastUpdated)
                        LegalFootnote(compact: true)
                    }
                    .listRowBackground(Color.clear)
                    Section {
                        ForEach(filtered) { c in
                            Button { toggle(c.code) } label: {
                                CountryRow(country: c, selected: selection.contains(c.code), showChevron: false)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onConfirm(Array(selection))
                        dismiss()
                    }
                    .disabled(selection.isEmpty && !multiSelect)
                }
            }
            .task {
                selection = Set(initialSelection)
            }
        }
    }

    private func toggle(_ code: String) {
        if multiSelect {
            if selection.contains(code) { selection.remove(code) } else { selection.insert(code) }
        } else {
            selection = [code]
        }
    }
}
