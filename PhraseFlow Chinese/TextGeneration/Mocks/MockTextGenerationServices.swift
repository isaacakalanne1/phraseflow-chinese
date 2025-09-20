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
    
    var generateChapterPreviousChaptersSpy: [Chapter]?
    var generateChapterDeviceLanguageSpy: Language?
    var generateChapterCalled = false
    var generateChapterResult: Result<Chapter, MockTextGenerationServicesError> = .success(.arrange)
    
    public func generateChapter(
        previousChapters: [Chapter],
        deviceLanguage: Language?
    ) async throws -> Chapter {
        generateChapterPreviousChaptersSpy = previousChapters
        generateChapterDeviceLanguageSpy = deviceLanguage
        generateChapterCalled = true
        
        switch generateChapterResult {
        case .success(let chapter):
            return chapter
        case .failure(let error):
            throw error
        }
    }
    
    var generateFirstChapterLanguageSpy: Language?
    var generateFirstChapterDifficultySpy: Difficulty?
    var generateFirstChapterVoiceSpy: Voice?
    var generateFirstChapterDeviceLanguageSpy: Language?
    var generateFirstChapterStoryPromptSpy: String?
    var generateFirstChapterCalled = false
    var generateFirstChapterResult: Result<Chapter, MockTextGenerationServicesError> = .success(.arrange)
    
    public func generateFirstChapter(
        language: Language,
        difficulty: Difficulty,
        voice: Voice,
        deviceLanguage: Language?,
        storyPrompt: String?
    ) async throws -> Chapter {
        generateFirstChapterLanguageSpy = language
        generateFirstChapterDifficultySpy = difficulty
        generateFirstChapterVoiceSpy = voice
        generateFirstChapterDeviceLanguageSpy = deviceLanguage
        generateFirstChapterStoryPromptSpy = storyPrompt
        generateFirstChapterCalled = true
        
        switch generateFirstChapterResult {
        case .success(let chapter):
            return chapter
        case .failure(let error):
            throw error
        }
    }
}