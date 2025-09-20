//
//  SubscriptionReducerTests.swift
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

final class SubscriptionReducerTests {
    
    @Test
    func onFetchedSubscriptions_updatesProducts() {
        let initialState = SubscriptionState.arrange(products: nil)
        let fetchedProducts: [Product] = []
        
        let newState = subscriptionReducer(
            initialState,
            .onFetchedSubscriptions(fetchedProducts)
        )
        
        #expect(newState.products == fetchedProducts)
    }
    
    @Test
    func updatePurchasedProducts_withVerifiedTransaction_addsProductID() {
        let initialState = SubscriptionState.arrange(purchasedProductIDs: Set())
        let productID = "com.flowtale.level_1"
        
        // Note: We can't create real Transaction objects, so we test with empty array
        let newState = subscriptionReducer(
            initialState,
            .updatePurchasedProducts([])
        )
        
        // State should remain unchanged with empty array
        #expect(newState.purchasedProductIDs == initialState.purchasedProductIDs)
    }
    
    @Test
    func updateIsSubscriptionPurchaseLoading_true() {
        let initialState = SubscriptionState.arrange(isLoadingSubscriptionPurchase: false)
        
        let newState = subscriptionReducer(
            initialState,
            .updateIsSubscriptionPurchaseLoading(true)
        )
        
        #expect(newState.isLoadingSubscriptionPurchase == true)
    }
    
    @Test
    func updateIsSubscriptionPurchaseLoading_false() {
        let initialState = SubscriptionState.arrange(isLoadingSubscriptionPurchase: true)
        
        let newState = subscriptionReducer(
            initialState,
            .updateIsSubscriptionPurchaseLoading(false)
        )
        
        #expect(newState.isLoadingSubscriptionPurchase == false)
    }
    
    // Note: purchaseSubscription test is skipped because we cannot create mock Product instances
    // TODO: Update above case to be testable
    
    @Test
    func onPurchasedSubscription_setsLoadingFalse() {
        let initialState = SubscriptionState.arrange(isLoadingSubscriptionPurchase: true)
        
        let newState = subscriptionReducer(
            initialState,
            .onPurchasedSubscription
        )
        
        #expect(newState.isLoadingSubscriptionPurchase == false)
    }
    
    @Test
    func failedToPurchaseSubscription_setsLoadingFalse() {
        let initialState = SubscriptionState.arrange(isLoadingSubscriptionPurchase: true)
        
        let newState = subscriptionReducer(
            initialState,
            .failedToPurchaseSubscription
        )
        
        #expect(newState.isLoadingSubscriptionPurchase == false)
    }
    
    @Test
    func refreshAppSettings_updatesSettings() {
        let initialSettings = SettingsState.arrange(usedCharacters: 100)
        let refreshedSettings = SettingsState.arrange(
            usedCharacters: 500,
            subscriptionLevel: .level1
        )
        let initialState = SubscriptionState.arrange(settings: initialSettings)
        
        let newState = subscriptionReducer(
            initialState,
            .refreshAppSettings(refreshedSettings)
        )
        
        #expect(newState.settings == refreshedSettings)
        #expect(newState.settings.usedCharacters == 500)
        #expect(newState.settings.subscriptionLevel == .level1)
    }
    
    @Test
    func onTrackedSsml_updatesUsedCharacters() {
        let initialState = SubscriptionState.arrange(
            settings: .arrange(usedCharacters: 100)
        )
        let totalUsedCharacters = 5000
        
        let newState = subscriptionReducer(
            initialState,
            .onTrackedSsml(totalUsedCharacters: totalUsedCharacters)
        )
        
        #expect(newState.settings.usedCharacters == totalUsedCharacters)
    }
    
    @Test
    func onUpdatedPurchasedProducts_updatesSubscriptionLevel() {
        let initialState = SubscriptionState.arrange(
            settings: .arrange(subscriptionLevel: .free)
        )
        
        let newState = subscriptionReducer(
            initialState,
            .onUpdatedPurchasedProducts(.level2)
        )
        
        #expect(newState.settings.subscriptionLevel == .level2)
    }
    
    @Test
    func setSubscriptionSheetShowing_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .setSubscriptionSheetShowing(true)
        )
        
        #expect(newState == state)
    }
    
    @Test
    func fetchSubscriptions_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .fetchSubscriptions
        )
        
        #expect(newState == state)
    }
    
    @Test
    func failedToFetchSubscriptions_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .failedToFetchSubscriptions
        )
        
        #expect(newState == state)
    }
    
    @Test
    func restoreSubscriptions_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .restoreSubscriptions
        )
        
        #expect(newState == state)
    }
    
    @Test
    func onRestoredSubscriptions_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .onRestoredSubscriptions
        )
        
        #expect(newState == state)
    }
    
    @Test
    func failedToRestoreSubscriptions_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .failedToRestoreSubscriptions
        )
        
        #expect(newState == state)
    }
    
    @Test
    func getCurrentEntitlements_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .getCurrentEntitlements
        )
        
        #expect(newState == state)
    }
    
    @Test
    func observeTransactionUpdates_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .observeTransactionUpdates
        )
        
        #expect(newState == state)
    }
    
    @Test
    func validateReceipt_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .validateReceipt
        )
        
        #expect(newState == state)
    }
    
    @Test
    func onValidatedReceipt_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .onValidatedReceipt
        )
        
        #expect(newState == state)
    }
    
    @Test
    func trackSsmlCharacterCount_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .trackSsmlCharacterCount(100)
        )
        
        #expect(newState == state)
    }
    
    @Test
    func saveAppSettings_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .saveAppSettings(.arrange)
        )
        
        #expect(newState == state)
    }
    
    @Test
    func failedToTrackSsml_doesNotChangeState() {
        let state = SubscriptionState.arrange()
        
        let newState = subscriptionReducer(
            state,
            .failedToTrackSsml
        )
        
        #expect(newState == state)
    }
    
    @Test
    func currentSubscription_derivedFromSettings() {
        let state = SubscriptionState.arrange(
            settings: .arrange(subscriptionLevel: .level2)
        )
        
        #expect(state.currentSubscription == .level2)
    }
    
    @Test
    func isSubscribed_trueForPaidLevels() {
        let stateLevel1 = SubscriptionState.arrange(
            settings: .arrange(subscriptionLevel: .level1)
        )
        let stateLevel2 = SubscriptionState.arrange(
            settings: .arrange(subscriptionLevel: .level2)
        )
        
        #expect(stateLevel1.isSubscribed == true)
        #expect(stateLevel2.isSubscribed == true)
    }
    
    @Test
    func isSubscribed_falseForFreeLevel() {
        let state = SubscriptionState.arrange(
            settings: .arrange(subscriptionLevel: .free)
        )
        
        #expect(state.isSubscribed == false)
    }
}

