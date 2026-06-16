import SwiftUI

enum AppTheme {
    static let radiusSM: CGFloat = 10
    static let radiusMD: CGFloat = 16
    static let radiusLG: CGFloat = 22
    static let spacingXS: CGFloat = 6
    static let spacingSM: CGFloat = 10
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    static let brandGradient = LinearGradient(
        colors: [Color.appGold, Color.appBrand, Color.appBrandDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let actionGradient = LinearGradient(
        colors: [Color.appAction, Color.appActionDark],
        startPoint: .top,
        endPoint: .bottom
    )

    static let heroGradient = LinearGradient(
        colors: [Color.appRed, Color.appRedDark, Color.appBackgroundBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    static let appRed = Color(red: 0.78, green: 0.09, blue: 0.14)
    static let appRedDark = Color(red: 0.52, green: 0.03, blue: 0.08)
    static let appBrand = Color(red: 0.96, green: 0.78, blue: 0.28)
    static let appBrandDark = Color(red: 0.72, green: 0.52, blue: 0.10)
    static let appBrandLight = Color(red: 0.62, green: 0.14, blue: 0.16)
    static let appAction = Color(red: 0.16, green: 0.74, blue: 0.36)
    static let appActionDark = Color(red: 0.08, green: 0.52, blue: 0.24)
    static let appGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let appSurface = Color(red: 0.48, green: 0.06, blue: 0.10)
    static let appBorder = Color(red: 0.96, green: 0.78, blue: 0.28).opacity(0.35)
    static let appBackgroundTop = Color(red: 0.78, green: 0.09, blue: 0.14)
    static let appBackgroundBottom = Color(red: 0.35, green: 0.02, blue: 0.05)
    static let appMuted = Color.white.opacity(0.72)
    static let appText = Color.white
}

struct FestiveBackground: View {
    var body: some View {
        ZStack {
            AppTheme.heroGradient

            GeometryReader { geo in
                Canvas { context, size in
                    let specs: [(x: CGFloat, y: CGFloat, r: CGFloat, o: Double)] = [
                        (0.08, 0.12, 4, 0.35), (0.22, 0.06, 3, 0.25), (0.88, 0.10, 5, 0.30),
                        (0.94, 0.28, 3, 0.22), (0.12, 0.38, 3, 0.20), (0.76, 0.44, 4, 0.28),
                        (0.05, 0.62, 5, 0.18), (0.90, 0.58, 3, 0.24), (0.48, 0.18, 2, 0.30),
                        (0.62, 0.72, 4, 0.16), (0.30, 0.82, 3, 0.20), (0.82, 0.86, 5, 0.14)
                    ]
                    for spec in specs {
                        let rect = CGRect(
                            x: spec.x * size.width - spec.r,
                            y: spec.y * size.height - spec.r,
                            width: spec.r * 2,
                            height: spec.r * 2
                        )
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(Color.appGold.opacity(spec.o))
                        )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }

            RadialGradient(
                colors: [Color.appGold.opacity(0.12), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 320
            )
        }
        .ignoresSafeArea()
    }
}

struct AppScreenBackground: View {
    var body: some View {
        FestiveBackground()
    }
}

struct AppCardModifier: ViewModifier {
    var padding: CGFloat = AppTheme.spacingMD
    var elevated: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                LinearGradient(
                    colors: [Color.appSurface, Color.appSurface.opacity(0.88)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.appGold.opacity(0.55), Color.appBrand.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: elevated ? Color.black.opacity(0.28) : .clear,
                radius: elevated ? 12 : 0,
                y: elevated ? 6 : 0
            )
    }
}

struct AppAccentBarModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(color)
                .frame(width: 4)
            content
        }
    }
}

extension View {
    func appCard(padding: CGFloat = AppTheme.spacingMD, elevated: Bool = true) -> some View {
        modifier(AppCardModifier(padding: padding, elevated: elevated))
    }

    func appAccentBar(_ color: Color = .appGold) -> some View {
        modifier(AppAccentBarModifier(color: color))
    }

    func appScreen() -> some View {
        background { AppScreenBackground() }
            .foregroundStyle(Color.appText)
    }
}

struct AppToolbarAddButton: View {
    let action: () -> Void
    var label: String = "Add"

    var body: some View {
        Button {
            Haptic.light()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.body.weight(.bold))
                .foregroundStyle(Color.appRedDark)
                .frame(width: 34, height: 34)
                .background(AppTheme.brandGradient, in: Circle())
                .overlay(Circle().strokeBorder(Color.appGold.opacity(0.6), lineWidth: 1))
                .shadow(color: Color.appGold.opacity(0.4), radius: 6, y: 3)
        }
        .accessibilityLabel(label)
    }
}

struct AppPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.actionGradient, in: RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.appAction.opacity(0.45), radius: 8, y: 4)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Haptic.medium() }
            }
    }
}

struct AppSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(Color.appGold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.appBrandLight.opacity(0.6), in: RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                    .strokeBorder(Color.appGold.opacity(0.45), lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { Haptic.light() }
            }
    }
}

struct AppIconBadge: View {
    let symbol: String
    var size: CGFloat = 52
    var tint: Color = .appGold

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [tint.opacity(0.35), Color.appRedDark.opacity(0.9)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.appGold, tint.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
            Image(systemName: symbol)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(tint)
                .shadow(color: Color.black.opacity(0.25), radius: 2, y: 1)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.appGold.opacity(0.25), radius: 8, y: 4)
    }
}

enum NavigationBarFestiveStyle {
    static func apply() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.appGold)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.appGold)
    }
}
