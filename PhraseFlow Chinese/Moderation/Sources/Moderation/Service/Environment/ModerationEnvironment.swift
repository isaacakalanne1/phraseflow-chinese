//
//  ModerationEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Settings
import SnackBar

struct ModerationEnvironment: ModerationEnvironmentProtocol {
    let moderationServices: ModerationServicesProtocol
    let moderationDataStore: ModerationDataStoreProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    private let snackBarEnvironment: SnackBarEnvironmentProtocol
    
    init(moderationServices: ModerationServicesProtocol, moderationDataStore: ModerationDataStoreProtocol, settingsEnvironment: SettingsEnvironmentProtocol, snackBarEnvironment: SnackBarEnvironmentProtocol) {
        self.moderationServices = moderationServices
        self.moderationDataStore = moderationDataStore
        self.settingsEnvironment = settingsEnvironment
        self.snackBarEnvironment = snackBarEnvironment
    }
    
    init() {
        self.moderationServices = ModerationServices()
        self.moderationDataStore = ModerationDataStore()
        self.settingsEnvironment = SettingsEnvironment()
        self.snackBarEnvironment = SnackBarEnvironment()
    }
    
    func moderateText(_ text: String) async throws -> ModerationResponse {
        return try await moderationServices.moderateText(text)
    }
    
    
    func savePassedModerationPrompt(_ prompt: String) {
        settingsEnvironment.addCustomPrompt(prompt)
        settingsEnvironment.setStorySetting(.customPrompt(prompt))
        // Trigger save through the subject
        settingsEnvironment.settingsSubject.send(())
    }
    
    func showModerationPassedSnackBar() {
        snackBarEnvironment.showSnackBar(.passedModeration)
    }
    
    func showModerationFailedSnackBar() {
        snackBarEnvironment.showSnackBar(.didNotPassModeration)
    }
}
