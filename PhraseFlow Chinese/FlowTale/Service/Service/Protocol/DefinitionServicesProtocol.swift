//
//  DefinitionServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

protocol DefinitionServicesProtocol {
    func fetchDefinitions(in sentence: Sentence?,
                          story: Story,
                          deviceLanguage: Language) async throws -> [Definition]
}
