//
//  StudyEnvironment.swift
//  Study
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Combine
import Foundation
import Settings
import TextGeneration

public struct StudyEnvironment: StudyEnvironmentProtocol {
    public var definitionsSubject: CurrentValueSubject<[Definition]?, Never>
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> {
        settingsEnvironment.settingsUpdatedSubject
    }
    
    private let definitionServices: DefinitionServicesProtocol
    private let audioEnvironment: AudioEnvironmentProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    private let dataStore: DefinitionDataStoreProtocol
    
    public init(
        definitionServices: DefinitionServicesProtocol,
        dataStore: DefinitionDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol
    ) {
        self.definitionsSubject = .init(nil)
        self.definitionServices = definitionServices
        self.dataStore = dataStore
        self.audioEnvironment = audioEnvironment
        self.settingsEnvironment = settingsEnvironment
    }
    
    public func loadSentenceAudio(id: UUID) throws -> Data {
        return try dataStore.loadSentenceAudio(id: id)
    }
    
    public func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition] {
        return try await definitionServices.fetchDefinitions(in: sentence, chapter: chapter, deviceLanguage: deviceLanguage)
    }
    
    public func saveDefinitions(_ definitions: [Definition]) throws {
        definitionsSubject.send(definitions)
        try dataStore.saveDefinitions(definitions)
    }
    
    public func deleteDefinition(with id: UUID) throws {
        try dataStore.deleteDefinition(with: id)
    }
    
    public func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try dataStore.saveSentenceAudio(audioData, id: id)
    }
    
    public func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
    
    public func loadDefinitions() throws -> [Definition] {
        let definitions = try dataStore.loadDefinitions()
        definitionsSubject.send(definitions)
        return definitions
    }
    
    public func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws {
        try dataStore.cleanupDefinitionsNotInChapters(chapters)
    }
}
