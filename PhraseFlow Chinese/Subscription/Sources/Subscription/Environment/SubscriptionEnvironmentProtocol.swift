//
//  SubscriptionEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import StoreKit

public protocol SubscriptionEnvironmentProtocol {
    func getProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
    func validateReceipt()
}