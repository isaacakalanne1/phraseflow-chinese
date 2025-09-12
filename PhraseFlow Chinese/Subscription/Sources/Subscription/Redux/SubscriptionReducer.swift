//
//  SubscriptionReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import StoreKit

@MainActor
public let subscriptionReducer: Reducer<SubscriptionState, SubscriptionAction> = { state, action in
        var newState = state

        switch action {
        case .onFetchedSubscriptions(let subscriptions):
            newState.products = subscriptions
            
        case .updatePurchasedProducts(let entitlements, _):
            for result in entitlements {
                switch result {
                case .unverified(let transaction, _),
                        .verified(let transaction):
                    if transaction.revocationDate == nil {
                        newState.purchasedProductIDs.insert(transaction.productID)
                    } else {
                        newState.purchasedProductIDs.remove(transaction.productID)
                    }
                }
            }
            
        case .updateIsSubscriptionPurchaseLoading(let isLoading):
            newState.isLoadingSubscriptionPurchase = isLoading
            
        case .purchaseSubscription:
            newState.isLoadingSubscriptionPurchase = true
            
        case .onPurchasedSubscription,
             .failedToPurchaseSubscription:
            newState.isLoadingSubscriptionPurchase = false
            
        case .setSubscriptionSheetShowing,
             .fetchSubscriptions,
             .failedToFetchSubscriptions,
             .restoreSubscriptions,
             .onRestoredSubscriptions,
             .failedToRestoreSubscriptions,
             .getCurrentEntitlements,
             .observeTransactionUpdates,
             .validateReceipt,
             .onValidatedReceipt,
             .trackSsmlCharacterCount:
            break
        }

        return newState
}
