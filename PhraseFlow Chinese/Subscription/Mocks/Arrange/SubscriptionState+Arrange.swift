//
//  SubscriptionState+Arrange.swift
//  Subscription
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import DataStorage
import Settings
import SettingsMocks
import StoreKit
import Subscription

public extension SubscriptionState {
    static var arrange: SubscriptionState {
        .arrange()
    }
    
    static func arrange(
        isLoadingSubscriptionPurchase: Bool = false,
        settings: SettingsState = .arrange,
        products: [Product]? = nil,
        purchasedProductIDs: Set<String> = Set(),
        hasReachedFreeTrialLimit: Bool = false,
        nextAvailableDescription: String = ""
    ) -> SubscriptionState {
        .init(
            isLoadingSubscriptionPurchase: isLoadingSubscriptionPurchase,
            settings: settings,
            products: products,
            purchasedProductIDs: purchasedProductIDs,
            hasReachedFreeTrialLimit: hasReachedFreeTrialLimit,
            nextAvailableDescription: nextAvailableDescription
        )
    }
}
