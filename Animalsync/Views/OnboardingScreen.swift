import SwiftUI

struct OnboardingScreen: View {
    @State private var page = 0
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            FestiveBackground()

            TabView(selection: $page) {
                pageView(
                    icon: "pawprint.fill",
                    title: "Plan your pet's travel",
                    body: "Animalsync knows entry rules for 40+ countries and turns them into a step-by-step schedule for your pet."
                ).tag(0)

                pageView(
                    icon: "calendar.badge.clock",
                    title: "Reverse timeline",
                    body: "Set your destination and entry date. We calculate exact deadlines — when to vaccinate, test, and file paperwork."
                ).tag(1)

                disclaimerPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.dark)
    }

    private var disclaimerPage: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Spacer()
            AppIconBadge(symbol: "exclamationmark.shield.fill", size: 92, tint: .appGold)
            VStack(spacing: AppTheme.spacingSM) {
                Text("Reference Only")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appText)
                Text("Animalsync is a reference tool, not legal or veterinary advice. Pet entry rules change frequently. Always verify with the official embassy of your destination and your licensed veterinarian before travel.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, AppTheme.spacingLG)
            }
            Button(action: onFinish) {
                Text("I Understand — Get Started")
            }
            .buttonStyle(AppPrimaryButtonStyle())
            .padding(.horizontal, AppTheme.spacingXL)
            Spacer()
        }
        .padding()
    }

    private func pageView(icon: String, title: String, body: String) -> some View {
        VStack(spacing: AppTheme.spacingLG) {
            Spacer()
            AppIconBadge(symbol: icon, size: 100, tint: .appGold)
            VStack(spacing: AppTheme.spacingSM) {
                Text(title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appText)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(Color.appMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, AppTheme.spacingLG)
            }
            Spacer()
            Button("Continue") { withAnimation { page += 1 } }
                .buttonStyle(AppSecondaryButtonStyle())
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.bottom, 72)
        }
        .padding()
    }
}
