//
//  StudyEnvironmentProtocol.swift
//  Study
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Combine
import Foundation
import Settings
import TextGeneration

public protocol StudyEnvironmentProtocol {
    var definitionsSubject: CurrentValueSubject<[Definition]?, Never> { get }
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    
    func loadSentenceAudio(id: UUID) throws -> Data
    func deleteDefinition(with id: UUID) throws
    func playSound(_ sound: AppSound)
    func saveDefinitions(_ definitions: [Definition]) throws
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func fetchDefinitions(
        in sentence: Sentence?,
        chapter: Chapter,
        deviceLanguage: Language
    ) async throws -> [Definition]
    func loadDefinitions() throws -> [Definition]
    func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws
    func cleanupOrphanedSentenceAudioFiles() throws
}
