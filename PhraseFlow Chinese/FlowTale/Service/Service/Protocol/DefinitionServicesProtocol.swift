//
//  DefinitionServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

protocol DefinitionServicesProtocol {
    func fetchDefinitions(in sentence: Sentence?,
                          chapter: Chapter,
                          deviceLanguage: Language) async throws -> [Definition]
}
