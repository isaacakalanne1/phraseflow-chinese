//
//  MockTextGenerationServices.swift
//  TextGeneration
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Settings
import TextGeneration

enum MockTextGenerationServicesError: Error {
    case genericError
}

public class MockTextGenerationServices: TextGenerationServicesProtocol {
    
    public init() {}
    
    var generateChapterStoryPreviousChaptersSpy: [Chapter]?
    var generateChapterStoryLanguageSpy: Language?
    var generateChapterStoryDifficultySpy: Difficulty?
    var generateChapterStoryVoiceSpy: Voice?
    var generateChapterStoryStoryPromptSpy: String?
    var generateChapterStoryCalled = false
    var generateChapterStoryResult: Result<Chapter, MockTextGenerationServicesError> = .success(.arrange)
    
    public func generateChapterStory(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        storyPrompt: String?
    ) async throws -> Chapter {
        generateChapterStoryPreviousChaptersSpy = previousChapters
        generateChapterStoryLanguageSpy = language
        generateChapterStoryDifficultySpy = difficulty
        generateChapterStoryVoiceSpy = voice
        generateChapterStoryStoryPromptSpy = storyPrompt
        generateChapterStoryCalled = true
        
        switch generateChapterStoryResult {
        case .success(let chapter):
            return chapter
        case .failure(let error):
            throw error
        }
    }
    
    var formatStoryIntoSentencesChapterSpy: Chapter?
    var formatStoryIntoSentencesDeviceLanguageSpy: Language?
    var formatStoryIntoSentencesCalled = false
    var formatStoryIntoSentencesResult: Result<Chapter, MockTextGenerationServicesError> = .success(.arrange)
    
    public func formatStoryIntoSentences(
        chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter {
        formatStoryIntoSentencesChapterSpy = chapter
        formatStoryIntoSentencesDeviceLanguageSpy = deviceLanguage
        formatStoryIntoSentencesCalled = true
        
        switch formatStoryIntoSentencesResult {
        case .success(let chapter):
            return chapter
        case .failure(let error):
            throw error
        }
    }
}