//
//  SubscriptionState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 13/12/2024.
//

import Foundation
import StoreKit

struct SubscriptionState {
    var isSubscribed = false
    var products: [Product]?
    var purchasedProductIDs = Set<String>()
}
