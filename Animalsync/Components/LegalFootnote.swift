import SwiftUI

struct LegalFootnote: View {
    var compact: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "info.circle")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(compact
                 ? "Reference only — verify with embassy & vet."
                 : "Reference only. Pet entry rules change frequently. Always verify with the official embassy and your licensed veterinarian before travel.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 12) {
        LegalFootnote()
        LegalFootnote(compact: true)
    }
    .padding()
}
