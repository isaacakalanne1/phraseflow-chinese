//
//  ModerationEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

protocol ModerationEnvironmentProtocol {
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var snackBarEnvironment: SnackBarEnvironmentProtocol { get }
    
    func moderateText(_ text: String) async throws -> ModerationResponse
    func saveAppSettings()
}