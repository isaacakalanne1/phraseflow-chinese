//
//  SubscriptionState.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation
import DataStorage
import Settings
import StoreKit

public struct SubscriptionState: Equatable {
    public var isLoadingSubscriptionPurchase: Bool
    public var settings: SettingsState
    public var currentSubscription: SubscriptionLevel {
        settings.subscriptionLevel
    }

    public var isSubscribed: Bool {
        currentSubscription != .free
    }

    public var products: [Product]?
    public var purchasedProductIDs = Set<String>()

    public var hasReachedFreeTrialLimit: Bool
    public var nextAvailableDescription: String
    
    public init(
        isLoadingSubscriptionPurchase: Bool = false,
        settings: SettingsState = SettingsState(),
        products: [Product]? = nil,
        purchasedProductIDs: Set<String> = Set<String>(),
        hasReachedFreeTrialLimit: Bool = false,
        nextAvailableDescription: String = ""
    ) {
        self.isLoadingSubscriptionPurchase = isLoadingSubscriptionPurchase
        self.settings = settings
        self.products = products
        self.purchasedProductIDs = purchasedProductIDs
        self.hasReachedFreeTrialLimit = hasReachedFreeTrialLimit
        self.nextAvailableDescription = nextAvailableDescription
    }
}
