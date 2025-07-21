//
//  ModerationEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

protocol ModerationEnvironmentProtocol {
    var moderationDataStore: ModerationDataStoreProtocol { get }
    
    func moderateText(_ text: String) async throws -> ModerationResponse
    func saveAppSettings()
    func savePassedModerationPrompt(_ prompt: String)
    func showModerationPassedSnackBar()
    func showModerationFailedSnackBar()
}