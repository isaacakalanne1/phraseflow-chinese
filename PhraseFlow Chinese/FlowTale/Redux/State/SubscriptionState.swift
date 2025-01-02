//
//  SubscriptionState.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation
import StoreKit

struct SubscriptionState {
    var isSubscribed: Bool {
        #if DEBUG
            true
        #else
            !purchasedProductIDs.isEmpty
        #endif
    }
    var products: [Product]?
    var purchasedProductIDs = Set<String>()
}
