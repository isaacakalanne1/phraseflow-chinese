//
//  DefinitionEnvironmentProtocol.swift
//  Definition
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine

protocol DefinitionEnvironmentProtocol {
    var clearDefinitionSubject: CurrentValueSubject<Void, Never> { get }
    var definitionServices: DefinitionServicesProtocol { get }
    var definitionDataStore: DefinitionDataStoreProtocol { get }
    
    func clearCurrentDefinition()
    func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func loadSentenceAudio(id: UUID) throws -> Data
}
