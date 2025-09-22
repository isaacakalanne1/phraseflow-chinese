//
//  SubscriptionEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import Combine
import DataStorage
import Settings
import StoreKit
import SnackBar

public protocol SubscriptionEnvironmentProtocol {
    var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never> { get }
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    func getProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws
    func validateReceipt()
    func trackSSMLCharacterUsage(characterCount: Int,
                                 subscription: SubscriptionLevel) throws -> Int
    func saveAppSettings(_ settings: SettingsState) throws
    func getCurrentEntitlements() async -> [VerificationResult<Transaction>]
    func observeTransactionUpdates() async -> [VerificationResult<Transaction>]
    func restoreSubscriptions() async throws
    func setSnackbarType(_ type: SnackBarType)
}
