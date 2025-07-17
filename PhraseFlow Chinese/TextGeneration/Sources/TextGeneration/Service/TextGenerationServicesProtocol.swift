//
//  TextGenerationServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Settings

protocol TextGenerationServicesProtocol {
    func generateChapter(
        previousChapters: [Chapter],
        deviceLanguage: Language?
    ) async throws -> Chapter

    func generateFirstChapter(
        language: Language,
        difficulty: Difficulty,
        voice: Voice,
        deviceLanguage: Language?,
        storyPrompt: String?
    ) async throws -> Chapter
}
