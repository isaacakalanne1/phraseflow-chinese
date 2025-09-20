//
//  SubscriptionMiddlewareTests.swift
//  Subscription
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Testing
import StoreKit
@testable import DataStorage
@testable import Settings
@testable import SettingsMocks
@testable import Subscription
@testable import SubscriptionMocks

final class SubscriptionMiddlewareTests {
    
    let mockEnvironment: MockSubscriptionEnvironment
    
    init() {
        mockEnvironment = MockSubscriptionEnvironment()
    }
    
    @Test
    func fetchSubscriptions_success() async {
        let expectedProducts: [Product] = []
        mockEnvironment.getProductsResult = .success(expectedProducts)
        
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .fetchSubscriptions,
            mockEnvironment
        )
        
        #expect(resultAction == .onFetchedSubscriptions(expectedProducts))
        #expect(mockEnvironment.validateReceiptCalled == true)
        #expect(mockEnvironment.getProductsCalled == true)
    }
    
    @Test
    func fetchSubscriptions_error() async {
        mockEnvironment.getProductsResult = .failure(.genericError)
        
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .fetchSubscriptions,
            mockEnvironment
        )
        
        #expect(resultAction == .failedToFetchSubscriptions)
        #expect(mockEnvironment.validateReceiptCalled == true)
        #expect(mockEnvironment.getProductsCalled == true)
    }
    
    // Note: purchaseSubscription tests are skipped because we cannot create mock Product instances
    // @Test func purchaseSubscription_success() - Skipped: Cannot create mock Product instances
    // @Test func purchaseSubscription_error() - Skipped: Cannot create mock Product instances
    
    @Test
    func restoreSubscriptions_success() async {
        // Note: We can't properly test AppStore.sync() but we can verify validateReceipt is called
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .restoreSubscriptions,
            mockEnvironment
        )
        
        // The actual action depends on AppStore.sync() which we can't mock
        #expect(mockEnvironment.validateReceiptCalled == true)
    }
    
    @Test
    func validateReceipt() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .validateReceipt,
            mockEnvironment
        )
        
        #expect(resultAction == .onValidatedReceipt)
        #expect(mockEnvironment.validateReceiptCalled == true)
    }
    
    @Test
    func getCurrentEntitlements() async {
        // Note: Transaction.currentEntitlements cannot be mocked, so we verify the action type
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .getCurrentEntitlements,
            mockEnvironment
        )
        
        // The result will be .updatePurchasedProducts with empty array since we can't mock transactions
        if case .updatePurchasedProducts(let entitlements) = resultAction {
            #expect(entitlements.isEmpty)
        } else {
            Issue.record("Expected updatePurchasedProducts action")
        }
    }
    
    @Test
    func observeTransactionUpdates() async {
        // Note: Transaction.updates cannot be mocked, so we verify the action type
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .observeTransactionUpdates,
            mockEnvironment
        )
        
        // The result will be .updatePurchasedProducts with empty array since we can't mock transactions
        if case .updatePurchasedProducts(let entitlements) = resultAction {
            #expect(entitlements.isEmpty)
        } else {
            Issue.record("Expected updatePurchasedProducts action")
        }
    }
    
    @Test
    func updatePurchasedProducts_withLevel2Subscription() async {
        let state = SubscriptionState.arrange(
            purchasedProductIDs: ["com.flowtale.level_2"]
        )
        
        let resultAction = await subscriptionMiddleware(
            state,
            .updatePurchasedProducts([]),
            mockEnvironment
        )
        
        #expect(resultAction == .onUpdatedPurchasedProducts(.level2))
    }
    
    @Test
    func updatePurchasedProducts_withLevel1Subscription() async {
        let state = SubscriptionState.arrange(
            purchasedProductIDs: ["com.flowtale.level_1"]
        )
        
        let resultAction = await subscriptionMiddleware(
            state,
            .updatePurchasedProducts([]),
            mockEnvironment
        )
        
        #expect(resultAction == .onUpdatedPurchasedProducts(.level1))
    }
    
    @Test
    func updatePurchasedProducts_withNoSubscription() async {
        let state = SubscriptionState.arrange(
            purchasedProductIDs: []
        )
        
        let resultAction = await subscriptionMiddleware(
            state,
            .updatePurchasedProducts([]),
            mockEnvironment
        )
        
        #expect(resultAction == .onUpdatedPurchasedProducts(.free))
    }
    
    @Test
    func updatePurchasedProducts_withBothSubscriptions_prefersLevel2() async {
        let state = SubscriptionState.arrange(
            purchasedProductIDs: ["com.flowtale.level_1", "com.flowtale.level_2"]
        )
        
        let resultAction = await subscriptionMiddleware(
            state,
            .updatePurchasedProducts([]),
            mockEnvironment
        )
        
        #expect(resultAction == .onUpdatedPurchasedProducts(.level2))
    }
    
    @Test
    func onUpdatedPurchasedProducts_triggersTrackSsml() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .onUpdatedPurchasedProducts(.level1),
            mockEnvironment
        )
        
        #expect(resultAction == .trackSsmlCharacterCount(0))
    }
    
    @Test
    func saveAppSettings() async {
        let settings = SettingsState.arrange
        mockEnvironment.saveAppSettingsResult = .success(())
        
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .saveAppSettings(settings),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
        #expect(mockEnvironment.saveAppSettingsSpy == settings)
    }
    
    @Test
    func onPurchasedSubscription_triggersGetCurrentEntitlements() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .onPurchasedSubscription,
            mockEnvironment
        )
        
        #expect(resultAction == .getCurrentEntitlements)
    }
    
    @Test
    func onFetchedSubscriptions_triggersGetCurrentEntitlements() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .onFetchedSubscriptions([]),
            mockEnvironment
        )
        
        #expect(resultAction == .getCurrentEntitlements)
    }
    
    @Test(arguments: [
        (100, SubscriptionLevel.free),
        (500, SubscriptionLevel.level1),
        (1000, SubscriptionLevel.level2)
    ])
    func trackSsmlCharacterCount_success(count: Int, subscription: SubscriptionLevel) async {
        let totalUsed = 5000
        let state = SubscriptionState.arrange(
            settings: .arrange(subscriptionLevel: subscription)
        )
        mockEnvironment.trackSSMLCharacterUsageResult = .success(totalUsed)
        
        let resultAction = await subscriptionMiddleware(
            state,
            .trackSsmlCharacterCount(count),
            mockEnvironment
        )
        
        #expect(resultAction == .onTrackedSsml(totalUsedCharacters: totalUsed))
        #expect(mockEnvironment.trackSSMLCharacterUsageCalled == true)
        #expect(mockEnvironment.trackSSMLCharacterUsageCharacterCountSpy == count)
        #expect(mockEnvironment.trackSSMLCharacterUsageSubscriptionSpy == subscription)
    }
    
    @Test
    func trackSsmlCharacterCount_error() async {
        mockEnvironment.trackSSMLCharacterUsageResult = .failure(.genericError)
        
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .trackSsmlCharacterCount(100),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToTrackSsml)
        #expect(mockEnvironment.trackSSMLCharacterUsageCalled == true)
    }
    
    @Test
    func onTrackedSsml_triggersSaveAppSettings() async {
        let state = SubscriptionState.arrange(
            settings: .arrange(usedCharacters: 123)
        )
        
        let resultAction = await subscriptionMiddleware(
            state,
            .onTrackedSsml(totalUsedCharacters: 5000),
            mockEnvironment
        )
        
        #expect(resultAction == .saveAppSettings(state.settings))
    }
    
    @Test
    func failedToFetchSubscriptions_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .failedToFetchSubscriptions,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToPurchaseSubscription_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .failedToPurchaseSubscription,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func updateIsSubscriptionPurchaseLoading_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .updateIsSubscriptionPurchaseLoading(true),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onRestoredSubscriptions_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .onRestoredSubscriptions,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToRestoreSubscriptions_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .failedToRestoreSubscriptions,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onValidatedReceipt_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .onValidatedReceipt,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func setSubscriptionSheetShowing_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .setSubscriptionSheetShowing(true),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func refreshAppSettings_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .refreshAppSettings(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToTrackSsml_returnsNil() async {
        let resultAction = await subscriptionMiddleware(
            .arrange,
            .failedToTrackSsml,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
}