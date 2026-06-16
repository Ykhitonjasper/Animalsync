import SwiftUI
import SwiftData

struct SettingsScreen: View {
    private var store = StoreKitManager.shared
    private var updateService = CountryUpdateService.shared
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderLeadDays") private var reminderLeadDays = 3
    @Environment(\.modelContext) private var context
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                accountSection
                remindersSection
                dataSection
                aboutSection

                #if DEBUG
                debugSection
                #endif
            }
            .padding(AppTheme.spacingMD)
            .padding(.bottom, AppTheme.spacingLG)
        }
        .appScreen()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) { PaywallScreen() }
        .task {
            await updateService.checkForUpdates()
        }
    }

    private var accountSection: some View {
        AppFormSection(title: "Account", subtitle: store.isPro ? "Pro member" : "Free plan") {
            HStack(spacing: 14) {
                AppIconBadge(
                    symbol: store.isPro ? "sparkles" : "pawprint.fill",
                    size: 44,
                    tint: store.isPro ? .appGold : .appBrand
                )
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.isPro ? "Animalsync Pro" : "Free Plan")
                        .font(.body.weight(.bold))
                    Text(store.isPro ? "Unlimited access" : "1 pet, 1 active trip")
                        .font(.caption)
                        .foregroundStyle(Color.appMuted)
                }
                Spacer()
                if !store.isPro {
                    Button("Upgrade") { showPaywall = true }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.brandGradient, in: Capsule())
                }
            }
            .padding(AppTheme.spacingMD)
            .overlay(alignment: .bottom) { Divider().overlay(Color.appBorder) }

            AppFormButton(title: "Restore Purchases", icon: "arrow.clockwise") {
                Task { await store.restorePurchases() }
            }
        }
    }

    private var remindersSection: some View {
        AppFormSection(title: "Reminders", subtitle: "Deadline notifications") {
            AppFormToggle(
                title: "Notifications",
                subtitle: "Alerts before vaccinations and paperwork deadlines",
                isOn: $notificationsEnabled
            )
            .onChange(of: notificationsEnabled) { _, _ in
                Task { await syncNotifications() }
            }

            AppFormStepper(
                title: "Lead time: \(reminderLeadDays) day\(reminderLeadDays == 1 ? "" : "s")",
                value: $reminderLeadDays,
                range: 1...30
            )
            .onChange(of: reminderLeadDays) { _, _ in
                Task { await syncNotifications() }
            }
        }
    }

    private var dataSection: some View {
        AppFormSection(title: "Data", subtitle: "Country requirements database") {
            AppFormInfoRow(
                title: "Database updated",
                value: CountryService.shared.globalLastUpdated
            )
            AppFormInfoRow(
                title: "Countries covered",
                value: "\(CountryService.shared.countries.count)"
            )

            if updateService.updateAvailable {
                VStack(alignment: .leading, spacing: 8) {
                    Text("A bundled country database update is available.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, AppTheme.spacingMD)
                        .padding(.top, AppTheme.spacingSM)
                    AppFormButton(title: "Apply update", icon: "arrow.down.circle") {
                        updateService.applyBundledUpdate()
                    }
                }
            }

            AppFormButton(
                title: updateService.isChecking ? "Checking…" : "Check for updates",
                icon: "arrow.clockwise",
                isLoading: updateService.isChecking
            ) {
                Task { await updateService.checkForUpdates() }
            }

            if let checked = updateService.lastCheckDate {
                Text("Last checked \(checked.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(Color.appMuted)
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.bottom, AppTheme.spacingMD)
            }
        }
    }

    private var aboutSection: some View {
        AppFormSection(title: "About", subtitle: "Legal and support") {
            AppFormNavigationRow(title: "Legal & Disclaimer", icon: "doc.text") {
                LegalDisclaimerScreen()
            }
            AppFormLinkRow(
                title: "Privacy Policy",
                icon: "lock.shield",
                url: LegalLinks.privacyPolicy
            )
            AppFormLinkRow(
                title: "Terms of Service",
                icon: "doc.plaintext",
                url: LegalLinks.termsOfService
            )
            AppFormLinkRow(
                title: "Contact Support",
                icon: "envelope",
                url: LegalLinks.supportEmail
            )
            AppFormInfoRow(title: "Version", value: "1.0.0")
        }
    }

    #if DEBUG
    private var debugSection: some View {
        AppFormSection(title: "Debug") {
            AppFormButton(title: "Reset onboarding", icon: "arrow.counterclockwise") {
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
            }
            AppFormButton(title: "Reseed mock data", icon: "tray.full", role: .destructive) {
                reseedMockData()
            }
        }
    }
    #endif

    private func syncNotifications() async {
        await NotificationCoordinator.syncFromContext(
            context,
            enabled: notificationsEnabled,
            leadDays: reminderLeadDays
        )
    }

    #if DEBUG
    private func reseedMockData() {
        do {
            try context.delete(model: Pet.self)
            try context.delete(model: Trip.self)
            try context.delete(model: PetDocument.self)
            try context.save()
            MockSeeder.seed(into: context)
            UserDefaults.standard.set(true, forKey: "hasSeededMockData")
        } catch {
            UserDefaults.standard.set(false, forKey: "hasSeededMockData")
        }
    }
    #endif
}
