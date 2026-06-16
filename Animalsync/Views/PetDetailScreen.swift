import SwiftUI
import SwiftData

struct PetDetailScreen: View {
    let pet: Pet
    @Query private var allDocuments: [PetDocument]
    @Query private var allTrips: [Trip]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showEdit = false
    @State private var showVaccineEditor = false
    @State private var editingVaccine: Vaccine?
    @State private var showDeleteConfirm = false

    private var linkedDocs: [PetDocument] {
        allDocuments.filter { $0.petID == pet.id }
    }
    private var linkedTrips: [Trip] {
        allTrips.filter { $0.petID == pet.id }.sorted { $0.entryDate > $1.entryDate }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                vaccinesSection
                if !linkedDocs.isEmpty {
                    section(title: "Documents", subtitle: "\(linkedDocs.count) items") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(linkedDocs) { DocumentThumbnail(document: $0) }
                        }
                    }
                }
                if !linkedTrips.isEmpty {
                    section(title: "Trips") {
                        VStack(spacing: 10) {
                            ForEach(linkedTrips) { trip in
                                NavigationLink(value: trip) {
                                    TripCard(trip: trip, pet: pet, dimmed: trip.status == .past)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                LegalFootnote()
            }
            .padding(AppTheme.spacingMD)
        }
        .appScreen()
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Edit pet") { showEdit = true }
                    Button("Delete pet", role: .destructive) { showDeleteConfirm = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            PetCreateScreen(existingPet: pet)
        }
        .sheet(isPresented: $showVaccineEditor) {
            VaccineEditorScreen(pet: pet, existingVaccine: editingVaccine)
        }
        .navigationDestination(for: Trip.self) { trip in
            TimelineScreen(trip: trip)
        }
        .confirmationDialog("Delete \(pet.name)?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: deletePet)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All vaccinations stay with this pet profile. Trips and linked documents will remain but lose the pet link.")
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            PetAvatar(pet: pet, size: 80)
            VStack(alignment: .leading, spacing: 6) {
                Text("\(pet.species.label) · \(pet.breed)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appMuted)
                Text("\(pet.ageYears) years old")
                    .font(.title3.weight(.bold))
                if let chip = pet.chipNumber {
                    Label(chip, systemImage: "cpu")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appBrand)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appBrandLight, in: Capsule())
                } else {
                    Label("No microchip", systemImage: "exclamationmark.circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
        }
        .appCard()
    }

    private var vaccinesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionHeader(
                    title: "Vaccinations",
                    subtitle: pet.vaccines.isEmpty ? "None on record" : "\(pet.vaccines.count) on record"
                )
                Spacer()
                Button {
                    editingVaccine = nil
                    showVaccineEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            if pet.vaccines.isEmpty {
                Text("Add rabies and other vaccinations to track expiry before travel.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(pet.vaccines) { vaccine in
                        Button {
                            editingVaccine = vaccine
                            showVaccineEditor = true
                        } label: {
                            VaccineRow(vaccine: vaccine)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: title, subtitle: subtitle)
            content()
        }
    }

    private func deletePet() {
        for doc in linkedDocs {
            doc.petID = nil
        }
        context.delete(pet)
        try? context.save()
        dismiss()
    }
}

private struct VaccineRow: View {
    let vaccine: Vaccine

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "syringe.fill")
                .foregroundStyle(.tint)
                .frame(width: 32, height: 32)
                .background(.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(vaccine.name).font(.subheadline.weight(.semibold))
                Text("Given \(vaccine.administeredOn.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundStyle(.secondary)
                if let validUntil = vaccine.validUntil {
                    Text("Valid until \(validUntil.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundStyle(validUntil < Date() ? .red : .secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
