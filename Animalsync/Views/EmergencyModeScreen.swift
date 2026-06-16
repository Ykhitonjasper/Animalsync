import SwiftUI
import SwiftData

struct EmergencyModeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var pets: [Pet]
    @State private var selectedPet: Pet?
    @State private var reason: EmergencyReason?
    @State private var currentDestination: String = ""
    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    intro

                    section("1. Pick your pet") {
                        if pets.isEmpty {
                            Text("Add a pet first to use Plan B mode.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(pets) { pet in
                                PetSelectionRow(
                                    pet: pet,
                                    isSelected: selectedPet?.id == pet.id
                                ) {
                                    selectedPet = pet
                                }
                            }
                        }
                    }

                    section("2. What's the problem?") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(EmergencyReason.allCases) { r in
                                ReasonChip(reason: r, isSelected: reason == r) {
                                    reason = r
                                }
                            }
                        }
                    }

                    if let pet = selectedPet, let r = reason {
                        section("3. Diagnosis") {
                            let dest = CountryService.shared.country(byCode: currentDestination)
                            Text(EmergencyAdvisor.diagnosis(for: r, pet: pet, destination: dest))
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }

                        section("4. Plan B — countries to consider") {
                            let alts = EmergencyAdvisor.alternatives(for: r, pet: pet, currentDestination: currentDestination)
                            VStack(spacing: 10) {
                                ForEach(alts) { sugg in
                                    SuggestionCard(suggestion: sugg)
                                }
                            }
                        }
                    }

                    LegalFootnote()
                }
                .padding()
            }
            .navigationTitle("Plan B")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.title)
                    .foregroundStyle(.orange)
                Text("Plan B Mode")
                    .font(.title2.weight(.bold))
            }
            Text("Tell us what went wrong. We'll explain the most likely cause and suggest 3+ alternative destinations your pet can actually enter.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            content()
        }
    }
}

private struct PetSelectionRow: View {
    let pet: Pet
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                PetCard(pet: pet)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .padding(10)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct ReasonChip: View {
    let reason: EmergencyReason
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: reason.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : Color.accentColor)
                Text(reason.label)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity, minHeight: 78)
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private struct SuggestionCard: View {
    let suggestion: AlternativeSuggestion

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(suggestion.country.flag).font(.largeTitle)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(suggestion.country.name).font(.subheadline.weight(.semibold))
                    Spacer()
                    DifficultyBadge(difficulty: suggestion.country.difficulty)
                }
                if !suggestion.reasoning.isEmpty {
                    Text(suggestion.reasoning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                LastUpdatedLabel(dateString: suggestion.country.lastUpdated, compact: true)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
