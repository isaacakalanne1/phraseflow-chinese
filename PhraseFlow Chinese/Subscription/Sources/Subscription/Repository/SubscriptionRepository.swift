//
//  SubscriptionRepository.swift
//  FlowTale
//
//  Created by iakalann on 16/07/2025.
//

import StoreKit

public class SubscriptionRepository: SubscriptionRepositoryProtocol {
    
    public init() {}

    public func getProducts() async throws -> [Product] {
        return try await Product.products(for: [
            "com.flowtale.level_1",
            "com.flowtale.level_2",
            "com.flowtale.level_3",
        ])
    }

    public func purchase(_ product: Product) async throws {
        do {
            validateAppStoreReceipt()

            let result = try await product.purchase()
            switch result {
            case let .success(.verified(transaction)):
                await transaction.finish()
            case let .success(.unverified(transaction, _)):
                await transaction.finish()
            case .pending, .userCancelled:
                throw SubscriptionRepositoryError.failedToPurchaseSubscription
            @unknown default:
                throw SubscriptionRepositoryError.failedToPurchaseSubscription
            }
        } catch {
            throw SubscriptionRepositoryError.failedToPurchaseSubscription
        }
    }

    /// Validates the App Store receipt
    public func validateAppStoreReceipt() {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receiptURL.path)
        else {
            let request = SKReceiptRefreshRequest()
            request.start()
            return
        }
    }
    
    public func getCurrentEntitlements() async -> Set<String> {
        var productIDs = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            switch result {
            case let .verified(transaction):
                productIDs.insert(transaction.productID)
            case .unverified:
                // Handle unverified transactions if needed
                break
            }
        }
        
        return productIDs
    }
    
}
