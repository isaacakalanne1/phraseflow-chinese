//
//  SubscriptionReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import StoreKit

let subscriptionReducer: Reducer<FlowTaleState, SubscriptionAction> = { state, action in
    var newState = state

    switch action {
    case .onFetchedSubscriptions(let subscriptions):
        newState.subscriptionState.products = subscriptions
        
    case .updatePurchasedProducts(let entitlements, _):
        for result in entitlements {
            switch result {
            case .unverified(let transaction, _),
                    .verified(let transaction):
                if transaction.revocationDate == nil {
                    newState.subscriptionState.purchasedProductIDs.insert(transaction.productID)
                } else {
                    newState.subscriptionState.purchasedProductIDs.remove(transaction.productID)
                }
            }
        }
        
    case .setSubscriptionSheetShowing(let isShowing):
        newState.viewState.isShowingSubscriptionSheet = isShowing
        if isShowing {
            newState.viewState.isWritingChapter = false
        }
        
    case .updateIsSubscriptionPurchaseLoading(let isLoading):
        newState.subscriptionState.isLoadingSubscriptionPurchase = isLoading
        
    case .purchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = true
        
    case .onPurchasedSubscription,
         .failedToPurchaseSubscription:
        newState.subscriptionState.isLoadingSubscriptionPurchase = false
        
    case .fetchSubscriptions,
         .failedToFetchSubscriptions,
         .restoreSubscriptions,
         .onRestoredSubscriptions,
         .failedToRestoreSubscriptions,
         .getCurrentEntitlements,
         .observeTransactionUpdates,
         .validateReceipt,
         .onValidatedReceipt:
        break
    }

    return newState
}
