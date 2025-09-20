//
//  SpeechEnvironmentTests.swift
//  Speech
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
import Settings
import TextGeneration
import TextGenerationMocks
@testable import Speech
@testable import SpeechMocks

class SpeechEnvironmentTests {
    let environment: SpeechEnvironmentProtocol
    let mockSpeechRepository: MockSpeechRepository
    
    init() {
        self.mockSpeechRepository = MockSpeechRepository()
        self.environment = SpeechEnvironment(
            speechRepository: mockSpeechRepository
        )
    }
    
    @Test
    func synthesizeSpeech_success() async throws {
        let chapter = Chapter.arrange
        let voice = Voice.elvira
        let language = Language.spanish
        let expectedChapter = Chapter.arrange(title: "Updated Chapter")
        let expectedCharacterCount = 150
        
        mockSpeechRepository.synthesizeSpeechResult = .success((expectedChapter, expectedCharacterCount))
        mockSpeechRepository.createSpeechSsmlReturn = String(repeating: "a", count: expectedCharacterCount)
        
        let result = try await environment.synthesizeSpeech(for: chapter, voice: voice, language: language)
        
        #expect(result == expectedChapter)
        #expect(mockSpeechRepository.synthesizeSpeechChapterSpy == chapter)
        #expect(mockSpeechRepository.synthesizeSpeechVoiceSpy == voice)
        #expect(mockSpeechRepository.synthesizeSpeechLanguageSpy == language)
        #expect(mockSpeechRepository.synthesizeSpeechCalled == true)
        #expect(mockSpeechRepository.createSpeechSsmlChapterSpy == chapter)
        #expect(mockSpeechRepository.createSpeechSsmlVoiceSpy == voice)
        #expect(mockSpeechRepository.createSpeechSsmlCalled == true)
        #expect(environment.synthesizedCharactersSubject.value == expectedCharacterCount)
    }
    
    @Test
    func synthesizeSpeech_error() async throws {
        let chapter = Chapter.arrange
        let voice = Voice.ava
        let language = Language.english
        
        mockSpeechRepository.synthesizeSpeechResult = .failure(.genericError)
        
        do {
            _ = try await environment.synthesizeSpeech(for: chapter, voice: voice, language: language)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockSpeechRepository.synthesizeSpeechChapterSpy == chapter)
            #expect(mockSpeechRepository.synthesizeSpeechVoiceSpy == voice)
            #expect(mockSpeechRepository.synthesizeSpeechLanguageSpy == language)
            #expect(mockSpeechRepository.synthesizeSpeechCalled == true)
            #expect(environment.synthesizedCharactersSubject.value == nil)
        }
    }
    
    @Test
    func synthesizeSpeech_chineseVoice() async throws {
        let chapter = Chapter.arrange(language: .mandarinChinese)
        let voice = Voice.xiaoxiao
        let language = Language.mandarinChinese
        let expectedChapter = Chapter.arrange(title: "Chinese Chapter")
        let expectedCharacterCount = 200
        
        mockSpeechRepository.synthesizeSpeechResult = .success((expectedChapter, expectedCharacterCount))
        mockSpeechRepository.createSpeechSsmlReturn = String(repeating: "中", count: expectedCharacterCount)
        
        let result = try await environment.synthesizeSpeech(for: chapter, voice: voice, language: language)
        
        #expect(result == expectedChapter)
        #expect(mockSpeechRepository.synthesizeSpeechChapterSpy == chapter)
        #expect(mockSpeechRepository.synthesizeSpeechVoiceSpy == voice)
        #expect(mockSpeechRepository.synthesizeSpeechLanguageSpy == language)
        #expect(environment.synthesizedCharactersSubject.value == expectedCharacterCount)
    }
    
    @Test
    func synthesizeSpeech_frenchVoice() async throws {
        let chapter = Chapter.arrange(language: .french)
        let voice = Voice.denise
        let language = Language.french
        let expectedChapter = Chapter.arrange(title: "French Chapter")
        let expectedCharacterCount = 120
        
        mockSpeechRepository.synthesizeSpeechResult = .success((expectedChapter, expectedCharacterCount))
        mockSpeechRepository.createSpeechSsmlReturn = String(repeating: "é", count: expectedCharacterCount)
        
        let result = try await environment.synthesizeSpeech(for: chapter, voice: voice, language: language)
        
        #expect(result == expectedChapter)
        #expect(mockSpeechRepository.synthesizeSpeechChapterSpy == chapter)
        #expect(mockSpeechRepository.synthesizeSpeechVoiceSpy == voice)
        #expect(mockSpeechRepository.synthesizeSpeechLanguageSpy == language)
        #expect(environment.synthesizedCharactersSubject.value == expectedCharacterCount)
    }
    
    @Test
    func synthesizeSpeech_emptyChapter() async throws {
        let chapter = Chapter.arrange(
            sentences: [],
            passage: "")
        let voice = Voice.andrew
        let language = Language.english
        let expectedChapter = Chapter.arrange(title: "Empty Chapter")
        let expectedCharacterCount = 0
        
        mockSpeechRepository.synthesizeSpeechResult = .success((expectedChapter, expectedCharacterCount))
        mockSpeechRepository.createSpeechSsmlReturn = ""
        
        let result = try await environment.synthesizeSpeech(for: chapter, voice: voice, language: language)
        
        #expect(result == expectedChapter)
        #expect(environment.synthesizedCharactersSubject.value == expectedCharacterCount)
    }
}
