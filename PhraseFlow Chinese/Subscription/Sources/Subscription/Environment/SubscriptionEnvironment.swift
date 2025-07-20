//
//  SubscriptionEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import StoreKit

public struct SubscriptionEnvironment: SubscriptionEnvironmentProtocol {
    private let repository: SubscriptionRepositoryProtocol
    
    public init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository()) {
        self.repository = repository
    }
    
    public func getProducts() async throws -> [Product] {
        return try await repository.getProducts()
    }
    
    public func purchase(_ product: Product) async throws {
        try await repository.purchase(product)
    }
    
    public func validateReceipt() {
        repository.validateAppStoreReceipt()
    }
}