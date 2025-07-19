//
//  SubscriptionEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import StoreKit

struct SubscriptionEnvironment: SubscriptionEnvironmentProtocol {
    private let repository: SubscriptionRepositoryProtocol
    
    init(repository: SubscriptionRepositoryProtocol = SubscriptionRepository()) {
        self.repository = repository
    }
    
    func getProducts() async throws -> [Product] {
        return try await repository.getProducts()
    }
    
    func purchase(_ product: Product) async throws {
        try await repository.purchase(product)
    }
    
    func validateReceipt() {
        repository.validateAppStoreReceipt()
    }
}