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
        return .updatePurchasedProducts(entitlements)
        
    case .observeTransactionUpdates:
        var entitlements: [VerificationResult<Transaction>] = []
        for await result in Transaction.updates {
            entitlements.append(result)
        }
        return .updatePurchasedProducts(entitlements)
        
    case .updatePurchasedProducts(let entitlements):
        
        // Determine the new subscription level
        let newSubscriptionLevel: SubscriptionLevel
        if state.purchasedProductIDs.contains("com.flowtale.level_2") {
            newSubscriptionLevel = .level2
        } else if state.purchasedProductIDs.contains("com.flowtale.level_1") {
            newSubscriptionLevel = .level1
        } else {
            newSubscriptionLevel = .free
        }
        var settings = state.settings
        settings.subscriptionLevel = newSubscriptionLevel
        return .onUpdatedPurchasedProducts(newSubscriptionLevel)
    case .onUpdatedPurchasedProducts:
        return .trackSsmlCharacterCount(0)
    case .saveAppSettings(let settings):
        try? environment.saveAppSettings(settings)
        return nil

    case .onPurchasedSubscription,
            .onFetchedSubscriptions:
        return .getCurrentEntitlements
        
    case .trackSsmlCharacterCount(let count):
        do {
            let totalUsedCharacters = try environment.trackSSMLCharacterUsage(characterCount: count,
                                                     subscription: state.currentSubscription)
            return .onTrackedSsml(totalUsedCharacters: totalUsedCharacters)
        } catch {
            return .failedToTrackSsml
        }
        
    case .onTrackedSsml:
        return .saveAppSettings(state.settings)

    case .failedToFetchSubscriptions,
         .failedToPurchaseSubscription,
         .updateIsSubscriptionPurchaseLoading,
         .onRestoredSubscriptions,
         .failedToRestoreSubscriptions,
         .onValidatedReceipt,
         .setSubscriptionSheetShowing,
         .refreshAppSettings,
         .failedToTrackSsml:
        return nil
    }
}
