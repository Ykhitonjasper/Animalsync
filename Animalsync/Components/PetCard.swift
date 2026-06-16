import SwiftUI

struct PetCard: View {
    let pet: Pet
    var trailing: AnyView? = nil
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            PetAvatar(pet: pet, size: compact ? 48 : 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(compact ? .subheadline.weight(.semibold) : .headline)
                Text("\(pet.species.label) · \(pet.breed)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appMuted)
                HStack(spacing: 6) {
                    Label("\(pet.ageYears) yr", systemImage: "calendar")
                    Text("·")
                    Label(pet.chipNumber == nil ? "No chip" : "Chipped", systemImage: "cpu")
                }
                .font(.caption)
                .foregroundStyle(Color.appMuted)
            }
            Spacer(minLength: 8)
            trailing
        }
        .contentShape(Rectangle())
    }
}
