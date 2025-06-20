//
//  FlowTaleServices.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

final class FlowTaleServices: FlowTaleServicesProtocol {
    private let createImageServices = CreateImageServices()
    private let createStoryServices = CreateStoryServices()
    private let definitionServices = DefinitionServices()
    private let moderationServices = ModerationServices()
    private let translationServices = TranslationServices()

    func generateImage(with prompt: String) async throws -> Data {
        try await createImageServices.generateImage(with: prompt)
    }

    func generateChapter(chapter: Chapter, deviceLanguage: Language?) async throws -> Chapter {
        try await createStoryServices.generateChapter(chapter: chapter,
                                                      deviceLanguage: deviceLanguage)
    }

    func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition] {
        try await definitionServices.fetchDefinitions(in: sentence,
                                                      chapter: chapter,
                                                      deviceLanguage: deviceLanguage)
    }

    func moderateText(_ text: String) async throws -> ModerationResponse {
        try await moderationServices.moderateText(text)
    }

    func translateText(
        _ text: String,
        from sourceLanguage: Language?,
        to targetLanguage: Language
    ) async throws -> Chapter {
        try await translationServices.translateText(text,
                                                    from: sourceLanguage,
                                                    to: targetLanguage)
    }

    func breakdownText(
        _ text: String,
        textLanguage: Language,
        deviceLanguage: Language
    ) async throws -> Chapter {
        try await translationServices.breakdownText(text,
                                                    textLanguage: textLanguage,
                                                    deviceLanguage: deviceLanguage)
    }
}
