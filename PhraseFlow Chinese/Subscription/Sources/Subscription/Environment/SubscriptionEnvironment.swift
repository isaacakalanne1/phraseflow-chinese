//
//  SubscriptionEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import Combine
import DataStorage
import StoreKit
import Speech
import UserLimit

public struct SubscriptionEnvironment: SubscriptionEnvironmentProtocol {
    private let repository: SubscriptionRepositoryProtocol
    private let speechEnvironment: SpeechEnvironmentProtocol
    private let userLimitsDataStore: UserLimitsDataStoreProtocol
    
    public var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never> {
        speechEnvironment.synthesizedCharactersSubject
    }
    
    public let currentSubscriptionSubject: CurrentValueSubject<SubscriptionLevel?, Never>
    
    public init(
        repository: SubscriptionRepositoryProtocol,
        speechEnvironment: SpeechEnvironmentProtocol,
        userLimitsDataStore: UserLimitsDataStoreProtocol
    ) {
        self.repository = repository
        self.speechEnvironment = speechEnvironment
        self.userLimitsDataStore = userLimitsDataStore
        self.currentSubscriptionSubject = CurrentValueSubject(nil)
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
    
    public func trackSSMLCharacterUsage(characterCount: Int,
                                        subscription: SubscriptionLevel?) throws {
        try userLimitsDataStore.trackSSMLCharacterUsage(characterCount: characterCount,
                                                        characterLimitPerDay: subscription?.ssmlCharacterLimitPerDay)
    }
}
