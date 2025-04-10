//
//  FlowTaleServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation

protocol FlowTaleServicesProtocol {
    func generateStory(story: Story,
                       deviceLanguage: Language?) async throws -> Story
                       
    func translateText(
        _ text: String,
        from sourceLanguage: Language?,
        to targetLanguage: Language
    ) async throws -> Chapter
    
    func breakdownText(
        _ text: String,
        textLanguage: Language,
        deviceLanguage: Language
    ) async throws -> Chapter
    
    func fetchDefinitions(in sentence: Sentence?,
                          story: Story,
                          deviceLanguage: Language) async throws -> [Definition]
    func generateImage(with prompt: String) async throws -> Data
    func moderateText(_ text: String) async throws -> ModerationResponse
}
