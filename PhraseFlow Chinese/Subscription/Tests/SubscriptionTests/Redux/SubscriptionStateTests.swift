//
//  SubscriptionStateTests.swift
//  Subscription
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Foundation
import DataStorage
import Settings
import SettingsMocks
import StoreKit
@testable import Subscription
@testable import SubscriptionMocks

class SubscriptionStateTests {
    
    @Test
    func initializer_setsDefaultValues() {
        let subscriptionState = SubscriptionState()
        
        #expect(subscriptionState.isLoadingSubscriptionPurchase == false)
        #expect(subscriptionState.settings == SettingsState())
        #expect(subscriptionState.products == nil)
        #expect(subscriptionState.purchasedProductIDs.isEmpty)
        #expect(subscriptionState.hasReachedFreeTrialLimit == false)
        #expect(subscriptionState.nextAvailableDescription == "")
    }
    
    @Test
    func initializer_withCustomValues() {
        let settings = SettingsState.arrange(subscriptionLevel: .level1)
        let productIDs: Set<String> = ["com.flowtale.level1", "com.flowtale.level2"]
        
        let subscriptionState = SubscriptionState(
            isLoadingSubscriptionPurchase: true,
            settings: settings,
            products: [],
            purchasedProductIDs: productIDs,
            hasReachedFreeTrialLimit: true,
            nextAvailableDescription: "Available tomorrow"
        )
        
        #expect(subscriptionState.isLoadingSubscriptionPurchase == true)
        #expect(subscriptionState.settings == settings)
        #expect(subscriptionState.products == [])
        #expect(subscriptionState.purchasedProductIDs == productIDs)
        #expect(subscriptionState.hasReachedFreeTrialLimit == true)
        #expect(subscriptionState.nextAvailableDescription == "Available tomorrow")
    }
    
    @Test
    func currentSubscription_returnsSettingsSubscriptionLevel() {
        let freeSettings = SettingsState.arrange(subscriptionLevel: .free)
        let level1Settings = SettingsState.arrange(subscriptionLevel: .level1)
        let level2Settings = SettingsState.arrange(subscriptionLevel: .level2)
        
        let freeState = SubscriptionState.arrange(settings: freeSettings)
        let level1State = SubscriptionState.arrange(settings: level1Settings)
        let level2State = SubscriptionState.arrange(settings: level2Settings)
        
        #expect(freeState.currentSubscription == .free)
        #expect(level1State.currentSubscription == .level1)
        #expect(level2State.currentSubscription == .level2)
    }
    
    @Test
    func isSubscribed_free_returnsFalse() {
        let settings = SettingsState.arrange(subscriptionLevel: .free)
        let subscriptionState = SubscriptionState.arrange(settings: settings)
        
        #expect(subscriptionState.isSubscribed == false)
    }
    
    @Test
    func isSubscribed_level1_returnsTrue() {
        let settings = SettingsState.arrange(subscriptionLevel: .level1)
        let subscriptionState = SubscriptionState.arrange(settings: settings)
        
        #expect(subscriptionState.isSubscribed == true)
    }
    
    @Test
    func isSubscribed_level2_returnsTrue() {
        let settings = SettingsState.arrange(subscriptionLevel: .level2)
        let subscriptionState = SubscriptionState.arrange(settings: settings)
        
        #expect(subscriptionState.isSubscribed == true)
    }
    
    @Test
    func equatable_sameStates() {
        let settings = SettingsState.arrange(subscriptionLevel: .level1)
        let productIDs: Set<String> = ["com.flowtale.level1"]
        
        let state1 = SubscriptionState.arrange(
            isLoadingSubscriptionPurchase: true,
            settings: settings,
            products: [],
            purchasedProductIDs: productIDs,
            hasReachedFreeTrialLimit: true,
            nextAvailableDescription: "Tomorrow"
        )
        
        let state2 = SubscriptionState.arrange(
            isLoadingSubscriptionPurchase: true,
            settings: settings,
            products: [],
            purchasedProductIDs: productIDs,
            hasReachedFreeTrialLimit: true,
            nextAvailableDescription: "Tomorrow"
        )
        
        #expect(state1 == state2)
    }
    
    @Test
    func equatable_differentIsLoadingSubscriptionPurchase() {
        let state1 = SubscriptionState.arrange(isLoadingSubscriptionPurchase: true)
        let state2 = SubscriptionState.arrange(isLoadingSubscriptionPurchase: false)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentSettings() {
        let settings1 = SettingsState.arrange(subscriptionLevel: .free)
        let settings2 = SettingsState.arrange(subscriptionLevel: .level1)
        
        let state1 = SubscriptionState.arrange(settings: settings1)
        let state2 = SubscriptionState.arrange(settings: settings2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentProducts() {
        let state1 = SubscriptionState.arrange(products: nil)
        let state2 = SubscriptionState.arrange(products: [])
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentPurchasedProductIDs() {
        let productIDs1: Set<String> = ["com.flowtale.level1"]
        let productIDs2: Set<String> = ["com.flowtale.level2"]
        
        let state1 = SubscriptionState.arrange(purchasedProductIDs: productIDs1)
        let state2 = SubscriptionState.arrange(purchasedProductIDs: productIDs2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentHasReachedFreeTrialLimit() {
        let state1 = SubscriptionState.arrange(hasReachedFreeTrialLimit: true)
        let state2 = SubscriptionState.arrange(hasReachedFreeTrialLimit: false)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentNextAvailableDescription() {
        let state1 = SubscriptionState.arrange(nextAvailableDescription: "Tomorrow")
        let state2 = SubscriptionState.arrange(nextAvailableDescription: "Next week")
        
        #expect(state1 != state2)
    }
    
    @Test
    func purchasedProductIDs_emptySet() {
        let subscriptionState = SubscriptionState.arrange(purchasedProductIDs: Set())
        
        #expect(subscriptionState.purchasedProductIDs.isEmpty)
    }
    
    @Test
    func purchasedProductIDs_multipleProducts() {
        let productIDs: Set<String> = [
            "com.flowtale.level1",
            "com.flowtale.level2",
            "com.flowtale.bonus"
        ]
        let subscriptionState = SubscriptionState.arrange(purchasedProductIDs: productIDs)
        
        #expect(subscriptionState.purchasedProductIDs.count == 3)
        #expect(subscriptionState.purchasedProductIDs.contains("com.flowtale.level1"))
        #expect(subscriptionState.purchasedProductIDs.contains("com.flowtale.level2"))
        #expect(subscriptionState.purchasedProductIDs.contains("com.flowtale.bonus"))
    }
    
    @Test
    func products_nilValue() {
        let subscriptionState = SubscriptionState.arrange(products: nil)
        
        #expect(subscriptionState.products == nil)
    }
    
    @Test
    func products_emptyArray() {
        let subscriptionState = SubscriptionState.arrange(products: [])
        
        #expect(subscriptionState.products != nil)
        #expect(subscriptionState.products?.isEmpty == true)
    }
    
    @Test
    func hasReachedFreeTrialLimit_true() {
        let subscriptionState = SubscriptionState.arrange(hasReachedFreeTrialLimit: true)
        
        #expect(subscriptionState.hasReachedFreeTrialLimit == true)
    }
    
    @Test
    func hasReachedFreeTrialLimit_false() {
        let subscriptionState = SubscriptionState.arrange(hasReachedFreeTrialLimit: false)
        
        #expect(subscriptionState.hasReachedFreeTrialLimit == false)
    }
    
    @Test
    func nextAvailableDescription_emptyString() {
        let subscriptionState = SubscriptionState.arrange(nextAvailableDescription: "")
        
        #expect(subscriptionState.nextAvailableDescription.isEmpty)
    }
    
    @Test
    func nextAvailableDescription_withValue() {
        let description = "Available in 2 hours"
        let subscriptionState = SubscriptionState.arrange(nextAvailableDescription: description)
        
        #expect(subscriptionState.nextAvailableDescription == description)
    }
}

