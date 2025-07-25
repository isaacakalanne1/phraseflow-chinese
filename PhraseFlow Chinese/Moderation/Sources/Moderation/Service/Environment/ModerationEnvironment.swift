//
//  ModerationEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import SnackBar

public struct ModerationEnvironment: ModerationEnvironmentProtocol {
    let moderationServices: ModerationServicesProtocol
    let moderationDataStore: ModerationDataStoreProtocol
    private let snackBarEnvironment: SnackBarEnvironmentProtocol
    
    public init(moderationServices: ModerationServicesProtocol,
         moderationDataStore: ModerationDataStoreProtocol,
         snackBarEnvironment: SnackBarEnvironmentProtocol) {
        self.moderationServices = moderationServices
        self.moderationDataStore = moderationDataStore
        self.snackBarEnvironment = snackBarEnvironment
    }
    
    public func moderateText(_ text: String) async throws -> ModerationResponse {
        return try await moderationServices.moderateText(text)
    }
    
    public func showModerationPassedSnackBar() {
        snackBarEnvironment.showSnackBar(.passedModeration)
    }
    
    public func showModerationFailedSnackBar() {
        snackBarEnvironment.showSnackBar(.didNotPassModeration)
    }
}
