import SwiftUI
import StoreKit

struct PaywallScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var store = StoreKitManager.shared
    @State private var selectedProductID = ProProductID.lifetime
    @State private var isPurchasing = false

    private let features: [(String, String)] = [
        ("pawprint.fill", "Unlimited pets"),
        ("airplane.departure", "Unlimited active trips"),
        ("doc.text.fill", "Unlimited document archive"),
        ("bell.badge.fill", "Smart deadline reminders"),
        ("globe", "Priority requirement updates")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.heroGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppTheme.spacingLG) {
                        header
                        featureList
                        planPicker
                        purchaseButton
                        restoreButton
                        subscriptionLegalSection
                        if let error = store.purchaseError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, AppTheme.spacingLG)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.appGold)
                }
            }
            .task {
                await reloadProductsIfNeeded()
            }
            .onChange(of: store.products.count) { _, _ in
                syncSelectedProduct()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            AppIconBadge(symbol: "pawprint.circle.fill", size: 84, tint: .appBrand)
            Text("Animalsync Pro")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.appGold)
            Text("Unlimited everything. Travel ready.")
                .font(.subheadline)
                .foregroundStyle(Color.appMuted)
        }
        .padding(.top, AppTheme.spacingMD)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(features, id: \.1) { icon, title in
                HStack(spacing: 12) {
                    AppIconBadge(symbol: icon, size: 36, tint: .appBrand)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .appCard()
        .padding(.horizontal, AppTheme.spacingMD)
    }

    @ViewBuilder
    private var planPicker: some View {
        if store.isLoading && store.products.isEmpty {
            ProgressView("Loading plans…")
                .padding()
        } else if store.products.isEmpty {
            VStack(spacing: 12) {
                Text("Purchase options couldn't be loaded.")
                    .font(.footnote)
                    .foregroundStyle(Color.appMuted)
                    .multilineTextAlignment(.center)
                Button("Try Again") {
                    Task { await reloadProductsIfNeeded(force: true) }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.appBrand)
            }
            .padding(.horizontal)
        } else {
            HStack(spacing: 10) {
                ForEach(store.products, id: \.id) { product in
                    planButton(product)
                }
            }
            .padding(.horizontal, AppTheme.spacingMD)
        }
    }

    private func planButton(_ product: Product) -> some View {
        let selected = selectedProductID == product.id
        let isLifetime = product.id == ProProductID.lifetime
        return Button { selectedProductID = product.id } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(isLifetime ? "Lifetime" : "Monthly")
                    .font(.subheadline.weight(.bold))
                Text(product.displayPrice)
                    .font(.title2.weight(.bold))
                Text(isLifetime ? "One-time purchase" : "Cancel anytime")
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(selected ? Color.appBrandLight : Color.appSurface, in: RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                    .strokeBorder(selected ? Color.appBrand : Color.appBorder, lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var purchaseButton: some View {
        Button {
            Task { await purchaseSelected() }
        } label: {
            Group {
                if isPurchasing || (store.isLoading && store.products.isEmpty) {
                    ProgressView().tint(.white)
                } else if store.isPro {
                    Text("You're Pro 🎉")
                } else if let product = store.product(for: selectedProductID) {
                    Text("Upgrade for \(product.displayPrice)")
                } else {
                    Text("Upgrade")
                }
            }
        }
        .buttonStyle(AppPrimaryButtonStyle())
        .disabled(store.isPro || isPurchasing || store.product(for: selectedProductID) == nil)
        .padding(.horizontal, AppTheme.spacingMD)
    }

    private var isMonthlySelected: Bool {
        selectedProductID == ProProductID.monthly
    }

    private var subscriptionLegalSection: some View {
        VStack(spacing: AppTheme.spacingSM) {
            Text(subscriptionDisclosureText)
                .font(.caption2)
                .foregroundStyle(Color.appMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: LegalLinks.privacyPolicy)
                Text("·").foregroundStyle(Color.appMuted)
                Link("Terms of Service", destination: LegalLinks.termsOfService)
            }
            .font(.caption.weight(.semibold))
            .tint(.appGold)

            LegalFootnote()
        }
        .padding(.horizontal, AppTheme.spacingMD)
    }

    private var subscriptionDisclosureText: String {
        if isMonthlySelected {
            return """
            Payment will be charged to your Apple ID account at confirmation of purchase. \
            The subscription renews every month unless canceled at least 24 hours before the end of the current period. \
            Your account will be charged for renewal within 24 hours prior to the end of the current period. \
            Manage or cancel subscriptions in your App Store account settings.
            """
        }
        return """
        Payment will be charged to your Apple ID account at confirmation of purchase. \
        Lifetime access is a one-time purchase with no recurring charges.
        """
    }

    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await store.restorePurchases()
                if store.isPro { dismiss() }
            }
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Color.appBrand)
        .disabled(isPurchasing)
    }

    private func reloadProductsIfNeeded(force: Bool = false) async {
        if force || !store.hasLoadedProducts || store.products.isEmpty {
            await store.loadProducts()
        }
        syncSelectedProduct()
    }

    private func syncSelectedProduct() {
        if store.product(for: ProProductID.lifetime) != nil {
            selectedProductID = ProProductID.lifetime
        } else if let first = store.products.first {
            selectedProductID = first.id
        }
    }

    private func purchaseSelected() async {
        guard let product = store.product(for: selectedProductID) else {
            await reloadProductsIfNeeded(force: true)
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        await store.purchase(product)
        if store.isPro {
            Haptic.success()
            dismiss()
        }
    }
}
