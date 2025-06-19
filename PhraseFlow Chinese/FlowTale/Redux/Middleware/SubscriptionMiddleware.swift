//
//  SubscriptionMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit
import StoreKit

let subscriptionMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .subscriptionAction(let subscriptionAction):
        switch subscriptionAction {
        case .fetchSubscriptions:
            environment.validateReceipt()
            do {
                let subscriptions = try await environment.getProducts()
                return .subscriptionAction(.onFetchedSubscriptions(subscriptions))
            } catch {
                return .subscriptionAction(.failedToFetchSubscriptions)
            }
            
        case .purchaseSubscription(let product):
            do {
                try await environment.purchase(product)
            } catch {
                return .subscriptionAction(.failedToPurchaseSubscription)
            }
            return .subscriptionAction(.onPurchasedSubscription)
            
        case .onPurchasedSubscription:
            return .subscriptionAction(.getCurrentEntitlements)
            
        case .restoreSubscriptions:
            environment.validateReceipt()
            do {
                try await AppStore.sync()
            } catch {
                return .subscriptionAction(.failedToRestoreSubscriptions)
            }
            return .subscriptionAction(.onRestoredSubscriptions)
            
        case .validateReceipt:
            environment.validateReceipt()
            return .subscriptionAction(.onValidatedReceipt)
            
        case .getCurrentEntitlements:
            var entitlements: [VerificationResult<Transaction>] = []
            for await result in Transaction.currentEntitlements {
                entitlements.append(result)
            }
            return .subscriptionAction(.updatePurchasedProducts(entitlements, isOnLaunch: true))
            
        case .observeTransactionUpdates:
            var entitlements: [VerificationResult<Transaction>] = []
            for await result in Transaction.updates {
                entitlements.append(result)
            }
            return .subscriptionAction(.updatePurchasedProducts(entitlements, isOnLaunch: false))
            
        case .updatePurchasedProducts(let entitlements, let isOnLaunch):
            for result in entitlements {
                switch result {
                case .unverified(let transaction, _),
                        .verified(let transaction):
                    if transaction.revocationDate == nil && !isOnLaunch {
                        return .snackbarAction(.showSnackBar(.subscribed))
                    } else {
                        return nil
                    }
                }
            }
            return nil
            
        case .setSubscriptionSheetShowing(let isShowing):
            if isShowing {
                return .snackbarAction(.hideSnackbar)
            }
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
    default:
        return nil
    }
}
