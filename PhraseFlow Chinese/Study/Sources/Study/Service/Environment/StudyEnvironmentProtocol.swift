//
//  StudyEnvironmentProtocol.swift
//  Study
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Settings
import TextGeneration

public protocol StudyEnvironmentProtocol {
    func loadSentenceAudio(id: UUID) throws -> Data
    func deleteDefinition(with id: UUID) throws
    func playSound(_ sound: AppSound)
    func saveDefinitions(_ definitions: [Definition]) throws
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func getAppSettings() throws -> SettingsState
    func fetchDefinitions(
        in sentence: Sentence?,
        chapter: Chapter,
        deviceLanguage: Language
    ) async throws -> [Definition]
    func loadDefinitions() throws -> [Definition]
}
