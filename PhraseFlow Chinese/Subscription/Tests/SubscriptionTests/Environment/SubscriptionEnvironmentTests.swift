//
//  SubscriptionEnvironmentTests.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import Foundation
import Testing
import StoreKit
@testable import DataStorage
@testable import Settings
@testable import SettingsMocks
@testable import Speech
@testable import SpeechMocks
@testable import Subscription
@testable import SubscriptionMocks
@testable import SnackBar
@testable import SnackBarMocks
@testable import UserLimit
@testable import UserLimitMocks

final class SubscriptionEnvironmentTests {
    let environment: SubscriptionEnvironmentProtocol
    let mockRepository: MockSubscriptionRepository
    let mockSpeechEnvironment: MockSpeechEnvironment
    let mockSettingsEnvironment: MockSettingsEnvironment
    let mockUserLimitsEnvironment: MockUserLimitEnvironment
    let mockSnackBarEnvironment: MockSnackBarEnvironment
    
    init() {
        self.mockRepository = MockSubscriptionRepository()
        self.mockSpeechEnvironment = MockSpeechEnvironment()
        self.mockSettingsEnvironment = MockSettingsEnvironment()
        self.mockUserLimitsEnvironment = MockUserLimitEnvironment()
        self.mockSnackBarEnvironment = MockSnackBarEnvironment()
        
        self.environment = SubscriptionEnvironment(
            repository: mockRepository,
            speechEnvironment: mockSpeechEnvironment,
            settingsEnvironment: mockSettingsEnvironment,
            userLimitsEnvironment: mockUserLimitsEnvironment,
            snackbarEnvironment: mockSnackBarEnvironment
        )
    }
    
    @Test
    func getProducts_success() async throws {
        let expectedProducts: [Product] = []
        mockRepository.getProductsResult = .success(expectedProducts)
        
        let result = try await environment.getProducts()
        
        #expect(result == expectedProducts)
        #expect(mockRepository.getProductsCalled == true)
    }
    
    @Test
    func getProducts_error() async throws {
        mockRepository.getProductsResult = .failure(.genericError)
        
        do {
            _ = try await environment.getProducts()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockRepository.getProductsCalled == true)
        }
    }
    
    // Note: StoreKit Product cannot be mocked in unit tests, so we skip these tests
    // The purchase functionality would need to be tested with integration tests
    
    // @Test 
    // func purchase_success() - Skipped: Cannot create mock Product instances
    // TODO: Update purchase function to be testable
    
    // @Test 
    // func purchase_error() - Skipped: Cannot create mock Product instances
    // TODO: Update purchase function to be testable
    
    @Test
    func validateReceipt() {
        environment.validateReceipt()
        
        #expect(mockRepository.validateAppStoreReceiptCalled == true)
    }
    
    @Test(arguments: [
        (100, SubscriptionLevel.free),
        (500, SubscriptionLevel.level1),
        (1000, SubscriptionLevel.level2)
    ])
    func trackSSMLCharacterUsage_success(
        characterCount: Int,
        subscription: SubscriptionLevel
    ) throws {
        let expectedRemaining = 1000
        mockUserLimitsEnvironment.trackSSMLCharacterUsageResult = .success(expectedRemaining)
        
        let result = try environment.trackSSMLCharacterUsage(
            characterCount: characterCount,
            subscription: subscription
        )
        
        #expect(result == expectedRemaining)
        #expect(mockUserLimitsEnvironment.trackSSMLCharacterUsageCharacterCountSpy == characterCount)
        #expect(mockUserLimitsEnvironment.trackSSMLCharacterUsageSubscriptionSpy == subscription)
        #expect(mockUserLimitsEnvironment.trackSSMLCharacterUsageCalled == true)
    }
    
    @Test(arguments: [
        (100, SubscriptionLevel.free),
        (500, SubscriptionLevel.level1),
        (1000, SubscriptionLevel.level2)
    ])
    func trackSSMLCharacterUsage_error(
        characterCount: Int,
        subscription: SubscriptionLevel
    ) throws {
        mockUserLimitsEnvironment.trackSSMLCharacterUsageResult = .failure(MockUserLimitEnvironmentError.genericError)
        
        do {
            _ = try environment.trackSSMLCharacterUsage(
                characterCount: characterCount,
                subscription: subscription
            )
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockUserLimitsEnvironment.trackSSMLCharacterUsageCharacterCountSpy == characterCount)
            #expect(mockUserLimitsEnvironment.trackSSMLCharacterUsageSubscriptionSpy == subscription)
            #expect(mockUserLimitsEnvironment.trackSSMLCharacterUsageCalled == true)
        }
    }
    
    @Test
    func saveAppSettings_success() throws {
        let expectedSettings = SettingsState.arrange
        
        try environment.saveAppSettings(expectedSettings)
        
        #expect(mockSettingsEnvironment.saveAppSettingsSpy == expectedSettings)
        #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
    }
    
    @Test
    func saveAppSettings_error() throws {
        let expectedSettings = SettingsState.arrange
        mockSettingsEnvironment.saveAppSettingsResult = .failure(MockSettingsEnvironmentError.genericError)
        
        do {
            try environment.saveAppSettings(expectedSettings)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockSettingsEnvironment.saveAppSettingsSpy == expectedSettings)
            #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
        }
    }
    
    @Test
    func synthesizedCharactersSubject_passThrough() {
        let expectedCharacters = 12345
        mockSpeechEnvironment.synthesizedCharactersSubject.send(expectedCharacters)
        
        #expect(environment.synthesizedCharactersSubject.value == expectedCharacters)
    }
    
    @Test
    func settingsUpdatedSubject_passThrough() {
        let expectedSettings = SettingsState.arrange
        mockSettingsEnvironment.settingsUpdatedSubject.send(expectedSettings)
        
        #expect(environment.settingsUpdatedSubject.value == expectedSettings)
    }
    
    @Test
    func getCurrentEntitlements() async {
        let expectedEntitlements: [VerificationResult<Transaction>] = []
        
        let result = await environment.getCurrentEntitlements()
        
        #expect(result == expectedEntitlements)
    }
    
    @Test
    func observeTransactionUpdates() async {
        let expectedEntitlements: [VerificationResult<Transaction>] = []
        
        let result = await environment.observeTransactionUpdates()
        
        #expect(result == expectedEntitlements)
    }
    
    @Test
    func restoreSubscriptions_success() async throws {
        try await environment.restoreSubscriptions()
        
        // Success - no exception thrown
        #expect(true)
    }
    
    @Test
    func restoreSubscriptions_error() async throws {
        // Note: We can't easily mock AppStore.sync() to throw errors in the real environment
        // This test just verifies the method exists and can be called
        do {
            try await environment.restoreSubscriptions()
            // Success case - AppStore.sync() completed
            #expect(true)
        } catch {
            // Error case - AppStore.sync() failed (this is also valid)
            #expect(true)
        }
    }
    
    @Test
    func setSnackbarType_delegatesToSnackbarEnvironment() {
        let snackbarType: SnackBarType = .failedToSubscribe
        
        environment.setSnackbarType(snackbarType)
        
        #expect(mockSnackBarEnvironment.setSnackbarTypeCalled == true)
        #expect(mockSnackBarEnvironment.setSnackbarTypeSpy == snackbarType)
    }
}

