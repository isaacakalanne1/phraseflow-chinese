//
//  SubscriptionEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import Combine
import DataStorage
import Settings
import StoreKit
import Speech
import UserLimit

public struct SubscriptionEnvironment: SubscriptionEnvironmentProtocol {
    private let repository: SubscriptionRepositoryProtocol
    private let speechEnvironment: SpeechEnvironmentProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    private let userLimitsDataStore: UserLimitsDataStoreProtocol
    
    public var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never> {
        speechEnvironment.synthesizedCharactersSubject
    }
    
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> {
        settingsEnvironment.settingsUpdatedSubject
    }
    
    public init(
        repository: SubscriptionRepositoryProtocol,
        speechEnvironment: SpeechEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        userLimitsDataStore: UserLimitsDataStoreProtocol
    ) {
        self.repository = repository
        self.speechEnvironment = speechEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.userLimitsDataStore = userLimitsDataStore
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
        settingsEnvironment.ssmlCharacterCountSubject.send(characterCount)
    }
    
    public func saveAppSettings(_ settings: SettingsState) throws {
        try settingsEnvironment.saveAppSettings(settings)
    }
}
