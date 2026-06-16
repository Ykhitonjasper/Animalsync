import SwiftUI
import SwiftData

struct TripDetailScreen: View {
    @Bindable var trip: Trip
    @Query private var pets: [Pet]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderLeadDays") private var reminderLeadDays = 3
    @State private var showDeleteConfirm = false
    @State private var notesText: String = ""

    private var pet: Pet? { pets.first { $0.id == trip.petID } }
    private var destination: CountryRequirement? {
        CountryService.shared.country(byCode: trip.destinationCountryCode)
    }

    private var tasks: [TimelineTask] {
        guard let pet else { return [] }
        return TimelineEngine.tasks(for: trip, pet: pet)
    }

    private var completionProgress: Double {
        guard !tasks.isEmpty else { return 0 }
        let done = tasks.filter(\.isCompleted).count
        return Double(done) / Double(tasks.count)
    }

    var body: some View {
        List {
            Section("Overview") {
                if let pet {
                    LabeledContent("Pet", value: "\(pet.species.emoji) \(pet.name)")
                }
                LabeledContent("Origin") {
                    FlagLabel(code: trip.originCountryCode)
                }
                if !trip.transitCountryCodes.isEmpty {
                    LabeledContent("Transit", value: trip.transitCountryCodes.joined(separator: ", "))
                }
                LabeledContent("Destination") {
                    FlagLabel(code: trip.destinationCountryCode)
                }
                LabeledContent("Entry date", value: trip.entryDate.formatted(date: .long, time: .omitted))
                if trip.daysUntilEntry > 0 {
                    LabeledContent("Countdown", value: "\(trip.daysUntilEntry) days")
                }
            }

            Section("Status") {
                Picker("Trip status", selection: $trip.status) {
                    ForEach(TripStatus.allCases, id: \.self) { status in
                        Label(status.label, systemImage: status.systemImage).tag(status)
                    }
                }
                .onChange(of: trip.status) { _, _ in
                    try? context.save()
                    Task { await rescheduleNotifications() }
                }

                if !tasks.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Requirements completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ProgressView(value: completionProgress)
                        Text("\(Int(completionProgress * 100))% · \(tasks.filter(\.isCompleted).count)/\(tasks.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Notes") {
                TextField("Vet appointments, airline confirmations…", text: $notesText, axis: .vertical)
                    .lineLimit(3...6)
                    .onChange(of: notesText) { _, newValue in
                        trip.notes = newValue.isEmpty ? nil : newValue
                        try? context.save()
                    }
            }

            if let dest = destination {
                Section("Destination info") {
                    DifficultyBadge(difficulty: dest.difficulty)
                    LastUpdatedLabel(dateString: dest.lastUpdated)
                    if let url = dest.officialSourceURL {
                        Link(destination: url) {
                            Label("Official source", systemImage: "globe")
                        }
                    }
                    if let notes = dest.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                NavigationLink {
                    TimelineScreen(trip: trip)
                } label: {
                    Label("Open timeline", systemImage: "calendar.badge.clock")
                }
            }

            Section {
                Button("Delete trip", role: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            notesText = trip.notes ?? ""
        }
        .confirmationDialog(
            "Delete this trip?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: deleteTrip)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone. Linked timeline progress will be lost.")
        }
    }

    private func deleteTrip() {
        context.delete(trip)
        try? context.save()
        Task { await rescheduleNotifications() }
        dismiss()
    }

    private func rescheduleNotifications() async {
        await NotificationCoordinator.syncFromContext(
            context,
            enabled: notificationsEnabled,
            leadDays: reminderLeadDays
        )
    }
}
