//
//  SettingsDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

protocol SettingsDataStoreProtocol {
    func loadAppSettings() throws -> SettingsState
    func saveAppSettings(_ settings: SettingsState) throws
}
