//
//  TranslationServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Settings
import TextGeneration

public protocol TranslationServicesProtocol {
    func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter
}
