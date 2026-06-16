import SwiftUI

struct EmergencyHubScreen: View {
    @State private var showEmergency = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                AppNavigationTitle(
                    title: "Help",
                    subtitle: "Emergency guidance, settings, and legal info"
                )

                Button { showEmergency = true } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            AppIconBadge(symbol: "exclamationmark.octagon.fill", size: 48, tint: .white)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Text("Refused at the border?")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Diagnose what went wrong and find Plan B countries your pet can actually enter.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.92))
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppTheme.spacingMD + 4)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.75, green: 0.22, blue: 0.18), Color(red: 0.92, green: 0.45, blue: 0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: AppTheme.radiusLG, style: .continuous)
                    )
                    .shadow(color: Color.red.opacity(0.25), radius: 14, y: 6)
                }
                .buttonStyle(.plain)

                VStack(spacing: 10) {
                    NavigationLink {
                        SettingsScreen()
                    } label: {
                        IconTextRow(icon: "gearshape.fill", title: "Settings", subtitle: "Notifications, account, updates")
                            .appCard(padding: AppTheme.spacingSM + 4, elevated: false)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        LegalDisclaimerScreen()
                    } label: {
                        IconTextRow(icon: "doc.text.magnifyingglass", title: "Legal & Disclaimers",
                                    subtitle: "How Animalsync sources its data", tint: .appMuted)
                            .appCard(padding: AppTheme.spacingSM + 4, elevated: false)
                    }
                    .buttonStyle(.plain)

                    DataFreshnessRow()
                        .appCard(padding: AppTheme.spacingSM + 4, elevated: false)
                }

                LegalFootnote()
            }
            .padding(.horizontal, AppTheme.spacingMD)
            .padding(.bottom, AppTheme.spacingLG)
        }
        .appScreen()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showEmergency) {
            EmergencyModeScreen()
        }
    }
}

private struct DataFreshnessRow: View {
    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(symbol: "clock.arrow.circlepath", size: 40, tint: .green)
            VStack(alignment: .leading, spacing: 3) {
                Text("Database updated")
                    .font(.body.weight(.semibold))
                Text(CountryService.shared.globalLastUpdated)
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
            }
            Spacer()
            Text("Latest")
                .font(.caption.weight(.bold))
                .foregroundStyle(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.green.opacity(0.12), in: Capsule())
        }
        .contentShape(Rectangle())
    }
}
