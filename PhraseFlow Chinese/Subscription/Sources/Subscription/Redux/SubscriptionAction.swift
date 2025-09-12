//
//  SubscriptionAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import Settings
import StoreKit

public enum SubscriptionAction: Sendable {
    case trackSsmlCharacterCount(Int)
    case fetchSubscriptions
    case onFetchedSubscriptions([Product])
    case failedToFetchSubscriptions
    
    case purchaseSubscription(Product)
    case onPurchasedSubscription
    case failedToPurchaseSubscription
    
    case updateIsSubscriptionPurchaseLoading(Bool)
    
    case restoreSubscriptions
    case onRestoredSubscriptions
    case failedToRestoreSubscriptions
    
    case getCurrentEntitlements
    case updatePurchasedProducts([VerificationResult<Transaction>], isOnLaunch: Bool)
    
    case observeTransactionUpdates
    case validateReceipt
    case onValidatedReceipt
    
    case setSubscriptionSheetShowing(Bool)
    
    case saveAppSettings(SettingsState)
    case refreshAppSettings(SettingsState)
}
