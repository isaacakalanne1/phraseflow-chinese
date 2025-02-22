//
//  SubscriptionState.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation
import StoreKit

struct SubscriptionState {
    var currentSubscription: SubscriptionLevel? {
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

    var isSubscribed: Bool {
//        #if DEBUG
//            true
//        #else
            currentSubscription != nil
//        #endif
    }
    var products: [Product]?
    var purchasedProductIDs = Set<String>()

    var hasReachedFreeTrialLimit = false
    var hasReachedDailyLimit = false
    var nextAvailableDescription = ""
}
