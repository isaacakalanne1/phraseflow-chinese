//
//  MockSpeechEnvironment.swift
//  Speech
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Combine
import Settings
import Speech
import TextGeneration

public class MockSpeechEnvironment: SpeechEnvironmentProtocol {
    public var synthesizedCharactersSubject: CurrentValueSubject<Int?, Never>
    
    public let speechRepository: SpeechRepositoryProtocol
    
    public init(
        synthesizedCharactersSubject: CurrentValueSubject<Int?, Never> = .init(nil),
        speechRepository: SpeechRepositoryProtocol = MockSpeechRepository()
    ) {
        self.synthesizedCharactersSubject = synthesizedCharactersSubject
        self.speechRepository = speechRepository
    }
    
    var synthesizeSpeechChapterSpy: Chapter?
    var synthesizeSpeechVoiceSpy: Voice?
    var synthesizeSpeechLanguageSpy: Language?
    var synthesizeSpeechCalled = false
    var synthesizeSpeechResult: Result<Chapter, MockSpeechRepositoryError> = .success(.arrange)
    public func synthesizeSpeech(
        for chapter: Chapter,
        voice: Voice,
        language: Language
    ) async throws -> Chapter {
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
}
