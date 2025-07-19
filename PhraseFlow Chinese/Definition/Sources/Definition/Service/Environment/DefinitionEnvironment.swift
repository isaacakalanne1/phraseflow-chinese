//
//  DefinitionEnvironment.swift
//  Definition
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

struct DefinitionEnvironment: DefinitionEnvironmentProtocol {
    let clearDefinitionSubject = CurrentValueSubject<Void, Never>(())
    let definitionServices: DefinitionServicesProtocol
    let definitionDataStore: DefinitionDataStoreProtocol
    
    func clearCurrentDefinition() {
        clearDefinitionSubject.send(())
    }
    
    func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition] {
        return try await definitionServices.fetchDefinitions(in: sentence, chapter: chapter, deviceLanguage: deviceLanguage)
    }
    
    func saveDefinitions(_ definitions: [Definition]) throws {
        try definitionDataStore.saveDefinitions(definitions)
    }
    
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try definitionDataStore.saveSentenceAudio(audioData, id: id)
    }
    
    func loadSentenceAudio(id: UUID) throws -> Data {
        return try definitionDataStore.loadSentenceAudio(id: id)
    }
}
