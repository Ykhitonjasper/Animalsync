import SwiftUI
import SwiftData

struct VaccineEditorScreen: View {
    @Bindable var pet: Pet
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var existingVaccine: Vaccine? = nil

    @State private var name = ""
    @State private var administeredOn = Date()
    @State private var hasExpiry = false
    @State private var validUntil = Date().addingTimeInterval(365 * 24 * 3600)
    @State private var batchNumber = ""
    @State private var notes = ""

    private let commonVaccines = [
        "Rabies", "DHPP", "FVRCP", "Bordetella", "Leptospirosis", "Lyme"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Vaccine") {
                    TextField("Name", text: $name)
                    Menu("Quick pick") {
                        ForEach(commonVaccines, id: \.self) { v in
                            Button(v) { name = v }
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Administered", selection: $administeredOn, displayedComponents: .date)
                    Toggle("Has expiry date", isOn: $hasExpiry)
                    if hasExpiry {
                        DatePicker("Valid until", selection: $validUntil, in: administeredOn..., displayedComponents: .date)
                    }
                }

                Section("Optional") {
                    TextField("Batch / lot number", text: $batchNumber)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                if existingVaccine != nil {
                    Section {
                        Button("Delete vaccination", role: .destructive, action: deleteVaccine)
                    }
                }
            }
            .navigationTitle(existingVaccine == nil ? "Add Vaccination" : "Edit Vaccination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .task {
                guard let v = existingVaccine else { return }
                name = v.name
                administeredOn = v.administeredOn
                hasExpiry = v.validUntil != nil
                validUntil = v.validUntil ?? validUntil
                batchNumber = v.batchNumber ?? ""
                notes = v.notes ?? ""
            }
        }
    }

    private func save() {
        let trimmedBatch = batchNumber.trimmingCharacters(in: .whitespaces)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
        let expiry = hasExpiry ? validUntil : nil

        if let existing = existingVaccine,
           let index = pet.vaccines.firstIndex(where: { $0.id == existing.id }) {
            pet.vaccines[index] = Vaccine(
                id: existing.id,
                name: name,
                administeredOn: administeredOn,
                validUntil: expiry,
                batchNumber: trimmedBatch.isEmpty ? nil : trimmedBatch,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
        } else {
            pet.vaccines.append(Vaccine(
                name: name,
                administeredOn: administeredOn,
                validUntil: expiry,
                batchNumber: trimmedBatch.isEmpty ? nil : trimmedBatch,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            ))
        }
        try? context.save()
        dismiss()
    }

    private func deleteVaccine() {
        guard let existing = existingVaccine else { return }
        pet.vaccines.removeAll { $0.id == existing.id }
        try? context.save()
        dismiss()
    }
}
