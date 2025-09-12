//
//  SubscriptionEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import Combine
import DataStorage
import Speech
import StoreKit

public protocol SubscriptionEnvironmentProtocol {
    var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never> { get }
    var currentSubscriptionSubject: CurrentValueSubject<SubscriptionLevel?, Never> { get }
    func getProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
    func validateReceipt()
    func trackSSMLCharacterUsage(characterCount: Int,
                                 subscription: SubscriptionLevel?) throws
    func getCurrentSubscriptionLevel() -> SubscriptionLevel?
    func fetchCurrentSubscriptionLevel() async -> SubscriptionLevel?
}
