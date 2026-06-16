import SwiftUI
import UIKit

struct GlassBg: View {
    var cornerRadius: CGFloat = AppTheme.radiusMD
    var borderOpacity: Double = 0.55

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.92),
                        Color.appRedDark.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.appGold.opacity(borderOpacity),
                                Color.appBrand.opacity(borderOpacity * 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.22), radius: 12, y: 6)
    }
}

struct GlassBgModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.radiusMD
    var padding: CGFloat = AppTheme.spacingMD

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                GlassBg(cornerRadius: cornerRadius)
            }
    }
}

extension View {
    func glassBg(
        cornerRadius: CGFloat = AppTheme.radiusMD,
        padding: CGFloat = AppTheme.spacingMD,
        material: Material = .ultraThinMaterial
    ) -> some View {
        modifier(GlassBgModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

enum TabBarGlassStyle {
    static func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.appRedDark.opacity(0.92))
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.25)

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor.white.withAlphaComponent(0.45)
        normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.45)]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = UIColor(Color.appGold)
        selected.titleTextAttributes = [.foregroundColor: UIColor(Color.appGold)]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(Color.appGold)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.45)
    }
}
