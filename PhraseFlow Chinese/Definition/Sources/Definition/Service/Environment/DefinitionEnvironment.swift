//
//  DefinitionEnvironment.swift
//  Definition
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import Settings
import TextGeneration

struct DefinitionEnvironment: DefinitionEnvironmentProtocol {
    let clearDefinitionSubject = CurrentValueSubject<Void, Never>(())
    
    private let definitionServices: DefinitionServicesProtocol
    private let audioEnvironment: AudioEnvironmentProtocol
    private let dataStore: DefinitionDataStoreProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    
    init(definitionServices: DefinitionServicesProtocol,
         dataStore: DefinitionDataStoreProtocol,
         audioEnvironment: AudioEnvironmentProtocol,
         settingsEnvironment: SettingsEnvironmentProtocol) {
        self.definitionServices = definitionServices
        self.dataStore = dataStore
        self.audioEnvironment = audioEnvironment
        self.settingsEnvironment = settingsEnvironment
    }
    
    func clearCurrentDefinition() {
        clearDefinitionSubject.send(())
    }
    
    func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition] {
        return try await definitionServices.fetchDefinitions(in: sentence, chapter: chapter, deviceLanguage: deviceLanguage)
    }
    
    func saveDefinitions(_ definitions: [Definition]) throws {
        try dataStore.saveDefinitions(definitions)
    }
    
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try dataStore.saveSentenceAudio(audioData, id: id)
    }
    
    func loadSentenceAudio(id: UUID) throws -> Data {
        return try dataStore.loadSentenceAudio(id: id)
    }
    
    func getAppSettings() throws -> SettingsState {
        return try settingsEnvironment.loadAppSettings()
    }
    
    func playSound(_ sound: AppSound) {
        audioEnvironment.playSound(sound)
    }
}
