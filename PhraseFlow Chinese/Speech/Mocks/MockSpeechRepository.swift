//
//  MockSpeechRepository.swift
//  Speech
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Settings
import Speech
import TextGeneration
import TextGenerationMocks

enum MockSpeechRepositoryError: Error {
    case genericError
}

public class MockSpeechRepository: SpeechRepositoryProtocol {
    
    public init() {
        
    }
    
    var synthesizeSpeechChapterSpy: Chapter?
    var synthesizeSpeechVoiceSpy: Voice?
    var synthesizeSpeechLanguageSpy: Language?
    var synthesizeSpeechCalled = false
    var synthesizeSpeechResult: Result<(Chapter, Int), MockSpeechRepositoryError> = .success((.arrange, 0))
    public func synthesizeSpeech(
        _ chapter: Chapter,
        voice: Voice,
        language: Language
    ) async throws -> (Chapter, Int) {
        synthesizeSpeechChapterSpy = chapter
        synthesizeSpeechVoiceSpy = voice
        synthesizeSpeechLanguageSpy = language
        synthesizeSpeechCalled = true
        switch synthesizeSpeechResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var createSpeechSsmlChapterSpy: Chapter?
    var createSpeechSsmlVoiceSpy: Voice?
    var createSpeechSsmlCalled = false
    var createSpeechSsmlReturn = ""
    public func createSpeechSsml(
        chapter: Chapter,
        voice: Voice
    ) -> String {
        createSpeechSsmlChapterSpy = chapter
        createSpeechSsmlVoiceSpy = voice
        createSpeechSsmlCalled = true
        return createSpeechSsmlReturn
    }
}
