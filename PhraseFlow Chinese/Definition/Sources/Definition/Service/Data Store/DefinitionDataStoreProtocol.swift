//
//  DefinitionDataStoreProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Combine
import Foundation

public protocol DefinitionDataStoreProtocol {
    func loadDefinitions() throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func deleteDefinition(with id: UUID) throws
    func cleanupOrphanedDefinitionFiles() throws

    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func loadSentenceAudio(id: UUID) throws -> Data
    func cleanupOrphanedSentenceAudioFiles() throws
}
