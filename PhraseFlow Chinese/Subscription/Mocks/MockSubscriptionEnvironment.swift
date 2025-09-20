//
//  MockSubscriptionEnvironment.swift
//  Subscription
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Combine
import DataStorage
import Foundation
import Settings
import StoreKit
import Subscription

enum MockSubscriptionEnvironmentError: Error {
    case genericError
}

public class MockSubscriptionEnvironment: SubscriptionEnvironmentProtocol {
    
    public var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never>
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    var mockRepository: MockSubscriptionRepository
    
    public init(
        synthesizedCharactersSubject: CurrentValueSubject<Int?, Never> = .init(nil),
        settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> = .init(nil),
        mockRepository: MockSubscriptionRepository = MockSubscriptionRepository()
    ) {
        self.synthesizedCharactersSubject = synthesizedCharactersSubject
        self.settingsUpdatedSubject = settingsUpdatedSubject
        self.mockRepository = mockRepository
    }
    
    var getProductsCalled = false
    var getProductsResult: Result<[Product], MockSubscriptionEnvironmentError> = .success([])
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
    var purchaseResult: Result<Void, MockSubscriptionEnvironmentError> = .success(())
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
    
    var validateReceiptCalled = false
    public func validateReceipt() {
        validateReceiptCalled = true
    }
    
    var trackSSMLCharacterUsageCharacterCountSpy: Int?
    var trackSSMLCharacterUsageSubscriptionSpy: SubscriptionLevel?
    var trackSSMLCharacterUsageCalled = false
    var trackSSMLCharacterUsageResult: Result<Int, MockSubscriptionEnvironmentError> = .success(0)
    public func trackSSMLCharacterUsage(characterCount: Int, subscription: SubscriptionLevel) throws -> Int {
        trackSSMLCharacterUsageCharacterCountSpy = characterCount
        trackSSMLCharacterUsageSubscriptionSpy = subscription
        trackSSMLCharacterUsageCalled = true
        switch trackSSMLCharacterUsageResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveAppSettingsSpy: SettingsState?
    var saveAppSettingsCalled = false
    var saveAppSettingsResult: Result<Void, MockSubscriptionEnvironmentError> = .success(())
    public func saveAppSettings(_ settings: SettingsState) throws {
        saveAppSettingsSpy = settings
        saveAppSettingsCalled = true
        switch saveAppSettingsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    public func getCurrentEntitlements() async -> [VerificationResult<Transaction>] {
        return await mockRepository.getCurrentEntitlementsDetailed()
    }
    
    public func observeTransactionUpdates() async -> [VerificationResult<Transaction>] {
        return await mockRepository.observeTransactionUpdates()
    }
    
    public func restoreSubscriptions() async throws {
        try await mockRepository.restoreSubscriptions()
    }
}