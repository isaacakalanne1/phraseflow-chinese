//
//  SubscriptionState.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation
import DataStorage
import StoreKit

public struct SubscriptionState: Equatable {
    public var isLoadingSubscriptionPurchase = false
    public var currentSubscription: SubscriptionLevel? {
//        #if DEBUG
//            .max
//        #else
        if purchasedProductIDs.contains("com.flowtale.level_2") {
            return .level2
        } else if purchasedProductIDs.contains("com.flowtale.level_1") {
            return .level1
        } else {
            return nil
        }
//        #endif
    }

    public var isSubscribed: Bool {
//        #if DEBUG
//            true
//        #else
            currentSubscription != nil
//        #endif
    }
    public var products: [Product]?
    public var purchasedProductIDs = Set<String>()

    public var hasReachedFreeTrialLimit = false
    public var nextAvailableDescription = ""
    
    public init() {}
}
