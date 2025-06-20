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
                return .subscriptionAction(.onPurchasedSubscription)
            } catch {
                return .subscriptionAction(.failedToPurchaseSubscription)
            }

        case .restoreSubscriptions:
            environment.validateReceipt()
            do {
                try await AppStore.sync()
                return .subscriptionAction(.onRestoredSubscriptions)
            } catch {
                return .subscriptionAction(.failedToRestoreSubscriptions)
            }
            
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
                    guard transaction.revocationDate == nil,
                          !isOnLaunch else {
                        return nil
                    }
                    return .snackbarAction(.showSnackBar(.subscribed))
                }
            }
            return nil

        case .onPurchasedSubscription:
            return .subscriptionAction(.getCurrentEntitlements)

        case .setSubscriptionSheetShowing(let isShowing):
            return isShowing ? .snackbarAction(.hideSnackbar) : nil

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
