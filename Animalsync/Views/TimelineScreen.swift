import SwiftUI
import SwiftData

struct TimelineScreen: View {
    @Bindable var trip: Trip
    @Query private var pets: [Pet]
    @Environment(\.modelContext) private var context
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderLeadDays") private var reminderLeadDays = 3
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable {
        case all, pending, done
        var label: String { rawValue.capitalized }
    }

    private var pet: Pet? { pets.first { $0.id == trip.petID } }

    private var tasks: [TimelineTask] {
        guard let pet else { return [] }
        return TimelineEngine.tasks(for: trip, pet: pet)
    }

    private var filtered: [TimelineTask] {
        switch filter {
        case .all: return tasks
        case .pending: return tasks.filter { !$0.isCompleted }
        case .done: return tasks.filter { $0.isCompleted }
        }
    }

    private var destination: CountryRequirement? {
        CountryService.shared.country(byCode: trip.destinationCountryCode)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                header
                Picker("Filter", selection: $filter) {
                    ForEach(Filter.allCases, id: \.self) { f in
                        Text(f.label).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(4)
                .background(Color.appSurface, in: RoundedRectangle(cornerRadius: AppTheme.radiusSM))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                        .strokeBorder(Color.appBorder, lineWidth: 1)
                )

                if filtered.isEmpty {
                    Text(tasks.isEmpty ? "No requirements found for this route." : "Nothing here yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { task in
                            NavigationLink(value: task) {
                                TimelineTaskRow(task: task, entryDate: trip.entryDate) {
                                    toggle(task)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if let url = destination?.officialSourceURL {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Verify on official source")
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appBrand)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.appBrandLight, in: RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                                .strokeBorder(Color.appBrand.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                LegalFootnote()
            }
            .padding(AppTheme.spacingMD)
        }
        .appScreen()
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    TripDetailScreen(trip: trip)
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("Trip details")
            }
        }
        .navigationDestination(for: TimelineTask.self) { task in
            RequirementDetailScreen(trip: trip, task: task)
        }
        .onAppear {
            Task { await syncNotifications() }
        }
        .onChange(of: trip.completedRequirementIDs) { _, _ in
            Task { await syncNotifications() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                FlagLabel(code: trip.destinationCountryCode)
                Spacer()
                if let d = destination?.difficulty {
                    DifficultyBadge(difficulty: d)
                }
            }
            if let pet {
                HStack(spacing: 8) {
                    PetAvatar(pet: pet, size: 30)
                    Text(pet.name)
                        .font(.subheadline.weight(.semibold))
                }
            }
            HStack(spacing: 12) {
                Label(trip.entryDate.formatted(date: .long, time: .omitted), systemImage: "calendar")
                    .font(.subheadline)
                if trip.daysUntilEntry > 0 {
                    Text("\(trip.daysUntilEntry) days left")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appBrand)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appBrandLight, in: Capsule())
                }
            }
            if let dest = destination {
                LastUpdatedLabel(dateString: dest.lastUpdated)
            }
        }
        .appCard()
    }

    private func toggle(_ task: TimelineTask) {
        if let idx = trip.completedRequirementIDs.firstIndex(of: task.requirementID) {
            trip.completedRequirementIDs.remove(at: idx)
            Haptic.light()
        } else {
            trip.completedRequirementIDs.append(task.requirementID)
            Haptic.success()
        }
        try? context.save()
    }

    private func syncNotifications() async {
        await NotificationCoordinator.syncFromContext(
            context,
            enabled: notificationsEnabled,
            leadDays: reminderLeadDays
        )
    }
}
