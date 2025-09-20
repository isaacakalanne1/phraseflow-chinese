//
//  MockSubscriptionRepository.swift
//  Subscription
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import StoreKit
import Subscription

enum MockSubscriptionRepositoryError: Error {
    case genericError
    case failedToPurchaseSubscription
}

public class MockSubscriptionRepository: SubscriptionRepositoryProtocol {
    
    public init() {
        
    }
    
    var getProductsCalled = false
    var getProductsResult: Result<[Product], MockSubscriptionRepositoryError> = .success([])
    public func getProducts() async throws -> [Product] {
        getProductsCalled = true
        switch getProductsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var purchaseProductSpy: Product?
    var purchaseCalled = false
    var purchaseResult: Result<Void, MockSubscriptionRepositoryError> = .success(())
    public func purchase(_ product: Product) async throws {
        purchaseProductSpy = product
        purchaseCalled = true
        switch purchaseResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var validateAppStoreReceiptCalled = false
    public func validateAppStoreReceipt() {
        validateAppStoreReceiptCalled = true
    }
    
    var getCurrentEntitlementsCalled = false
    var getCurrentEntitlementsReturn: Set<String> = []
    public func getCurrentEntitlements() async -> Set<String> {
        getCurrentEntitlementsCalled = true
        return getCurrentEntitlementsReturn
    }
}