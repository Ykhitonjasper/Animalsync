import SwiftUI

struct LegalDisclaimerScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reference Only")
                    .font(.title.weight(.bold))

                Group {
                    Text("Animalsync is a reference tool, not legal or veterinary advice.")
                        .font(.headline)
                    Text("Pet entry requirements change frequently and vary by species, breed, and origin. Always verify with the official embassy or consulate of your destination and your licensed veterinarian before traveling.")
                    Text("JaksTeam is not liable for refused entry, fines, quarantine, or other consequences resulting from outdated or incorrect information.")
                }
                .font(.subheadline)

                Divider().padding(.vertical, 6)

                Group {
                    Text("Data Sources").font(.headline)
                    bullet("USDA APHIS — pet travel rules into and out of the United States")
                    bullet("EU Regulation 576/2013 — non-commercial movement of pet animals")
                    bullet("UK gov.uk PETS — taking your pet abroad")
                    bullet("Country-specific ministry / customs sources (linked per country)")
                    Text("Each country entry shows its last update date and a deep link to the official authoritative source. Verify directly before any irreversible action.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .font(.subheadline)

                Divider().padding(.vertical, 6)

                Group {
                    Text("Privacy").font(.headline)
                    bullet("All your data stays on your device.")
                    bullet("Animalsync does not track you or share data with third parties.")
                    bullet("Documents are stored locally in your app's Application Support folder.")
                }
                .font(.subheadline)

                LegalFootnote()

                LabeledContent("Database last updated", value: CountryService.shared.globalLastUpdated)
                    .font(.caption)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Legal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }
}
