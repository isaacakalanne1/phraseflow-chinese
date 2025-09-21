//
//  TextGenerationServicesProtocol.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Settings

public protocol TextGenerationServicesProtocol {
    func generateChapterStory(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        storyPrompt: String?
    ) async throws -> Chapter
    
    func formatStoryIntoSentences(
        chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter
}
