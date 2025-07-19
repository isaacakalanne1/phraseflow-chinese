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
    private let settingsEnvironment: SettingsEnvironmentProtocol
    private let snackBarEnvironment: SnackBarEnvironmentProtocol
    
    func moderateText(_ text: String) async throws -> ModerationResponse {
        return try await moderationServices.moderateText(text)
    }
    
    func saveAppSettings() {
        settingsEnvironment.saveAppSettings()
    }
    
    func savePassedModerationPrompt(_ prompt: String) {
        settingsEnvironment.addCustomPrompt(prompt)
        settingsEnvironment.setStorySetting(.customPrompt(prompt))
    }
    
    func showModerationPassedSnackBar() {
        snackBarEnvironment.showSnackBar(.passedModeration)
    }
    
    func showModerationFailedSnackBar() {
        snackBarEnvironment.showSnackBar(.didNotPassModeration)
    }
}