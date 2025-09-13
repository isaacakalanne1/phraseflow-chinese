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
    public var isLoadingSubscriptionPurchase = false
    public var settings = SettingsState()
    public var currentSubscription: SubscriptionLevel {
        settings.subscriptionLevel
    }

    public var isSubscribed: Bool {
        currentSubscription != .free
    }

    public var products: [Product]?
    public var purchasedProductIDs = Set<String>()

    public var hasReachedFreeTrialLimit = false
    public var nextAvailableDescription = ""
    
    public init() {}
}
