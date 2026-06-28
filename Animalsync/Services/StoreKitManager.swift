import Foundation
import StoreKit

enum ProProductID {
    static let monthly = "com.TuyetMaiDoThi.Animalsync.pro.monthly"
    static let lifetime = "com.TuyetMaiDoThi.Animalsync.pro.lifetime"
    static let all = [monthly, lifetime]
}

@MainActor
@Observable
final class StoreKitManager {
    static let shared = StoreKitManager()

    private(set) var products: [Product] = []
    private(set) var isPro = false
    private(set) var isLoading = false
    private(set) var hasLoadedProducts = false
    private(set) var purchaseError: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = Task { await listenForTransactions() }
        Task { await refreshEntitlements() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        guard !isLoading else { return }
        isLoading = true
        purchaseError = nil
        defer {
            isLoading = false
            hasLoadedProducts = true
        }

        do {
            let loaded = try await Product.products(for: ProProductID.all)
            products = loaded.sorted { $0.price < $1.price }
            if products.isEmpty {
                purchaseError =
                    "Unable to load purchase options. Please check your connection and try again."
            }
        } catch {
            products = []
            purchaseError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                purchaseError = "Unknown purchase result."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        purchaseError = nil
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if ProProductID.all.contains(transaction.productID) {
                entitled = true
            }
        }
        isPro = entitled
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard let transaction = try? checkVerified(result) else { continue }
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: LocalizedError {
        case failedVerification

        var errorDescription: String? {
            "Transaction verification failed."
        }
    }
}
