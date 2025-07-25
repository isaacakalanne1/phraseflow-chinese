//
//  DefinitionServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Settings
import TextGeneration

public protocol DefinitionServicesProtocol {
    func fetchDefinitions(in sentence: Sentence?,
                          chapter: Chapter,
                          deviceLanguage: Language) async throws -> [Definition]
}
