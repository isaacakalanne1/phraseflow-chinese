//
//  SubscriptionRepositoryProtocol.swift
//  FlowTale
//
//  Created by iakalann on 16/07/2025.
//

import StoreKit

public protocol SubscriptionRepositoryProtocol {
    func getProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
    func validateAppStoreReceipt()
    func getCurrentEntitlements() async -> Set<String>
    func getCurrentEntitlementsDetailed() async -> [VerificationResult<Transaction>]
    func observeTransactionUpdates() async -> [VerificationResult<Transaction>]
    func restoreSubscriptions() async throws
}
