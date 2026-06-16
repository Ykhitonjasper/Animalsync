import SwiftUI
import SwiftData

struct TripCreateScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var pets: [Pet]
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderLeadDays") private var reminderLeadDays = 3

    @State private var step = 1
    @State private var selectedPet: Pet?
    @State private var origin: String = "RU"
    @State private var transit: [String] = []
    @State private var destination: String = ""
    @State private var entryDate = Date().addingTimeInterval(90 * 24 * 3600)

    @State private var pickerMode: PickerMode?

    enum PickerMode: Identifiable {
        case origin, transit, destination
        var id: String { String(describing: self) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    WizardStepHeader(
                        step: step,
                        total: 4,
                        title: stepTitle,
                        subtitle: stepSubtitle
                    )
                    stepContent
                    LegalFootnote(compact: true)
                }
                .padding(AppTheme.spacingMD)
            }
            .appScreen()
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(item: $pickerMode) { mode in
                CountryPickerScreen(
                    title: title(for: mode),
                    initialSelection: initial(for: mode),
                    multiSelect: mode == .transit
                ) { codes in
                    switch mode {
                    case .origin: origin = codes.first ?? origin
                    case .transit: transit = codes
                    case .destination: destination = codes.first ?? destination
                    }
                }
            }
        }
    }

    private var stepTitle: String {
        switch step {
        case 1: "Choose pet"
        case 2: "Where from?"
        case 3: "Any transit countries?"
        default: "Where to?"
        }
    }

    private var stepSubtitle: String {
        switch step {
        case 1: "Pick which pet is traveling."
        case 2: "Country where the trip begins."
        case 3: "Add stopovers. Skip if direct."
        default: "Destination country and entry date."
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 1:
            VStack(spacing: 10) {
                ForEach(pets) { pet in
                    Button {
                        selectedPet = pet
                    } label: {
                        HStack {
                            PetCard(pet: pet)
                            Image(systemName: selectedPet?.id == pet.id ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedPet?.id == pet.id ? Color.accentColor : Color.secondary)
                        }
                        .padding(10)
                        .appCard(padding: AppTheme.spacingSM + 4, elevated: false)
                    }
                    .buttonStyle(.plain)
                }
            }
        case 2:
            Button { pickerMode = .origin } label: {
                pickerRow(label: "Origin", code: origin)
            }
        case 3:
            VStack(alignment: .leading, spacing: 10) {
                Button { pickerMode = .transit } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill").foregroundStyle(.tint)
                        Text(transit.isEmpty ? "Add transit countries" : "Edit transit")
                        Spacer()
                    }
                    .padding()
                    .appCard(padding: AppTheme.spacingSM + 4, elevated: false)
                }
                .buttonStyle(.plain)
                if !transit.isEmpty {
                    ForEach(transit, id: \.self) { code in
                        if let c = CountryService.shared.country(byCode: code) {
                            CountryRow(country: c, showChevron: false)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .appCard(padding: AppTheme.spacingSM, elevated: false)
                        }
                    }
                }
            }
        default:
            VStack(alignment: .leading, spacing: 14) {
                Button { pickerMode = .destination } label: {
                    pickerRow(label: "Destination", code: destination.isEmpty ? nil : destination)
                }
                DatePicker("Entry Date",
                           selection: $entryDate,
                           in: Date()...,
                           displayedComponents: .date)
                    .padding()
                    .appCard(padding: AppTheme.spacingSM + 4, elevated: false)
            }
        }
    }

    private func pickerRow(label: String, code: String?) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            if let code, let c = CountryService.shared.country(byCode: code) {
                Text("\(c.flag) \(c.name)")
            } else {
                Text("Select").foregroundStyle(.tint)
            }
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
        }
        .appCard(padding: AppTheme.spacingSM + 4, elevated: false)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if step > 1 {
                Button("Back") { withAnimation { step -= 1 } }
                    .buttonStyle(AppSecondaryButtonStyle())
                    .frame(maxWidth: 120)
            }
            Button(step == 4 ? "Create Trip" : "Next") {
                if step == 4 { create() } else { withAnimation { step += 1 } }
            }
            .buttonStyle(AppPrimaryButtonStyle())
            .disabled(!canAdvance)
            .opacity(canAdvance ? 1 : 0.5)
        }
        .glassBg(cornerRadius: 0, padding: AppTheme.spacingMD, material: .ultraThinMaterial)
        .background(Color.clear)
    }

    private var canAdvance: Bool {
        switch step {
        case 1: return selectedPet != nil
        case 2: return !origin.isEmpty
        case 3: return true
        default: return !destination.isEmpty
        }
    }

    private func title(for mode: PickerMode) -> String {
        switch mode {
        case .origin: "Origin"
        case .transit: "Transit"
        case .destination: "Destination"
        }
    }

    private func initial(for mode: PickerMode) -> [String] {
        switch mode {
        case .origin: [origin]
        case .transit: transit
        case .destination: destination.isEmpty ? [] : [destination]
        }
    }

    private func create() {
        guard let pet = selectedPet else { return }
        let trip = Trip(
            petID: pet.id,
            originCountryCode: origin,
            transitCountryCodes: transit,
            destinationCountryCode: destination,
            entryDate: entryDate,
            status: .planning
        )
        context.insert(trip)
        try? context.save()
        Task {
            await NotificationCoordinator.syncFromContext(
                context,
                enabled: notificationsEnabled,
                leadDays: reminderLeadDays
            )
        }
        dismiss()
    }
}
