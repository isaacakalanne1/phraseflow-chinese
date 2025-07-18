//
//  ModerationEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Settings

struct ModerationEnvironment: ModerationEnvironmentProtocol {
    let moderationServices: ModerationServicesProtocol
    let settingsEnvironment: SettingsEnvironmentProtocol
    let snackBarEnvironment: SnackBarEnvironmentProtocol
    
    func moderateText(_ text: String) async throws -> ModerationResponse {
        return try await moderationServices.moderateText(text)
    }
    
    func saveAppSettings() {
        settingsEnvironment.saveAppSettings()
    }
}