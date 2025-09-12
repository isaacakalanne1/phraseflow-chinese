//
//  SubscriptionMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit
import DataStorage
import StoreKit

@MainActor
public let subscriptionMiddleware: Middleware<SubscriptionState, SubscriptionAction, SubscriptionEnvironmentProtocol> = { state, action, environment in
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
        // Calculate the new subscription level after updating purchased products
        var newPurchasedProductIDs = state.purchasedProductIDs
        
        for result in entitlements {
            switch result {
            case .unverified(let transaction, _),
                    .verified(let transaction):
                if transaction.revocationDate == nil {
                    newPurchasedProductIDs.insert(transaction.productID)
                } else {
                    newPurchasedProductIDs.remove(transaction.productID)
                }
                guard transaction.revocationDate == nil,
                      !isOnLaunch else {
                    return nil
                }
                return nil
            }
        }
        
        // Determine the new subscription level
        let newSubscriptionLevel: SubscriptionLevel
        if newPurchasedProductIDs.contains("com.flowtale.level_2") {
            newSubscriptionLevel = .level2
        } else if newPurchasedProductIDs.contains("com.flowtale.level_1") {
            newSubscriptionLevel = .level1
        } else {
            #if DEBUG
            newSubscriptionLevel = .max
            #else
            newSubscriptionLevel = .free
            #endif
        }
        
        // Publish the new subscription level
        environment.currentSubscriptionSubject.send(newSubscriptionLevel)
        var settings = state.settings
        settings.subscriptionLevel = newSubscriptionLevel
        return .saveAppSettings(settings)
    case .saveAppSettings(let settings):
        try? environment.saveAppSettings(settings)
        return nil

    case .onPurchasedSubscription,
            .onFetchedSubscriptions:
        return .getCurrentEntitlements
        
    case .trackSsmlCharacterCount(let count):
        try? environment.trackSSMLCharacterUsage(characterCount: count,
                                                 subscription: state.currentSubscription)
        return nil

    case .failedToFetchSubscriptions,
         .failedToPurchaseSubscription,
         .updateIsSubscriptionPurchaseLoading,
         .onRestoredSubscriptions,
         .failedToRestoreSubscriptions,
         .onValidatedReceipt,
         .setSubscriptionSheetShowing,
         .refreshAppSettings:
        return nil
    }
}
