//
//  SubscriptionMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit
import StoreKit

let subscriptionMiddleware: Middleware<SubscriptionState, SubscriptionAction, SubscriptionEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .fetchSubscriptions:
        environment.validateReceipt()
        do {
            let subscriptions = try await environment.getProducts()
            return .onFetchedSubscriptions(subscriptions)
        } catch {
            return .failedToFetchSubscriptions
        }
        
    case .purchaseSubscription(let product):
        do {
            try await environment.purchase(product)
            return .onPurchasedSubscription
        } catch {
            return .failedToPurchaseSubscription
        }

    case .restoreSubscriptions:
        environment.validateReceipt()
        do {
            try await AppStore.sync()
            return .onRestoredSubscriptions
        } catch {
            return .failedToRestoreSubscriptions
        }
        
    case .validateReceipt:
        environment.validateReceipt()
        return .onValidatedReceipt
        
    case .getCurrentEntitlements:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.currentEntitlements {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements, isOnLaunch: true)
        
    case .observeTransactionUpdates:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.updates {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements, isOnLaunch: false)
        
    case .updatePurchasedProducts(let entitlements, let isOnLaunch):
        for result in entitlements {
            switch result {
            case .unverified(let transaction, _),
                    .verified(let transaction):
                guard transaction.revocationDate == nil,
                      !isOnLaunch else {
                    return nil
                }
                return nil
            }
        }
        return nil

    case .onPurchasedSubscription:
        return .getCurrentEntitlements

    case .setSubscriptionSheetShowing:
        return nil

    case .onFetchedSubscriptions,
         .failedToFetchSubscriptions,
         .failedToPurchaseSubscription,
         .updateIsSubscriptionPurchaseLoading,
         .onRestoredSubscriptions,
         .failedToRestoreSubscriptions,
         .onValidatedReceipt:
        return nil
    }
}
