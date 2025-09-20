//
//  StudyEnvironmentTests.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Testing
@testable import Audio
@testable import AudioMocks
@testable import Settings
@testable import SettingsMocks
@testable import Study
@testable import StudyMocks
@testable import TextGeneration
@testable import TextGenerationMocks

class StudyEnvironmentTests {
    let environment: StudyEnvironmentProtocol
    let mockDefinitionServices: MockDefinitionServices
    let mockDataStore: MockDefinitionDataStore
    let mockAudioEnvironment: MockAudioEnvironment
    let mockSettingsEnvironment: MockSettingsEnvironment
    
    init() {
        self.mockDefinitionServices = MockDefinitionServices()
        self.mockDataStore = MockDefinitionDataStore()
        self.mockAudioEnvironment = MockAudioEnvironment()
        self.mockSettingsEnvironment = MockSettingsEnvironment()
        
        self.environment = StudyEnvironment(
            definitionServices: mockDefinitionServices,
            dataStore: mockDataStore,
            audioEnvironment: mockAudioEnvironment,
            settingsEnvironment: mockSettingsEnvironment
        )
    }
    
    @Test
    func loadSentenceAudio_success() throws {
        let expectedId = UUID()
        let expectedData = Data("test audio data".utf8)
        mockDataStore.loadSentenceAudioResult = .success(expectedData)
        
        let result = try environment.loadSentenceAudio(id: expectedId)
        
        #expect(result == expectedData)
        #expect(mockDataStore.loadSentenceAudioSpy == expectedId)
        #expect(mockDataStore.loadSentenceAudioCalled == true)
    }
    
    @Test
    func loadSentenceAudio_error() throws {
        let expectedId = UUID()
        mockDataStore.loadSentenceAudioResult = .failure(.genericError)
        
        do {
            _ = try environment.loadSentenceAudio(id: expectedId)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.loadSentenceAudioSpy == expectedId)
            #expect(mockDataStore.loadSentenceAudioCalled == true)
        }
    }
    
    @Test
    func fetchDefinitions_success() async throws {
        let expectedSentence = Sentence.arrange
        let expectedChapter = Chapter.arrange
        let expectedDeviceLanguage = Language.english
        let expectedDefinitions = [Definition.arrange, Definition.arrange]
        mockDefinitionServices.fetchDefinitionsResult = .success(expectedDefinitions)
        
        let result = try await environment.fetchDefinitions(
            in: expectedSentence,
            chapter: expectedChapter,
            deviceLanguage: expectedDeviceLanguage
        )
        
        #expect(result == expectedDefinitions)
        #expect(mockDefinitionServices.fetchDefinitionsSentenceSpy == expectedSentence)
        #expect(mockDefinitionServices.fetchDefinitionsChapterSpy == expectedChapter)
        #expect(mockDefinitionServices.fetchDefinitionsDeviceLanguageSpy == expectedDeviceLanguage)
        #expect(mockDefinitionServices.fetchDefinitionsCalled == true)
    }
    
    @Test
    func fetchDefinitions_error() async throws {
        let expectedSentence = Sentence.arrange
        let expectedChapter = Chapter.arrange
        let expectedDeviceLanguage = Language.english
        mockDefinitionServices.fetchDefinitionsResult = .failure(.genericError)
        
        do {
            _ = try await environment.fetchDefinitions(
                in: expectedSentence,
                chapter: expectedChapter,
                deviceLanguage: expectedDeviceLanguage
            )
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDefinitionServices.fetchDefinitionsSentenceSpy == expectedSentence)
            #expect(mockDefinitionServices.fetchDefinitionsChapterSpy == expectedChapter)
            #expect(mockDefinitionServices.fetchDefinitionsDeviceLanguageSpy == expectedDeviceLanguage)
            #expect(mockDefinitionServices.fetchDefinitionsCalled == true)
        }
    }
    
    @Test
    func saveDefinitions_success() throws {
        let expectedDefinitions = [Definition.arrange, Definition.arrange]
        
        try environment.saveDefinitions(expectedDefinitions)
        
        #expect(mockDataStore.saveDefinitionsSpy == expectedDefinitions)
        #expect(mockDataStore.saveDefinitionsCalled == true)
        #expect(environment.definitionsSubject.value == expectedDefinitions)
    }
    
    @Test
    func saveDefinitions_error() throws {
        let expectedDefinitions = [Definition.arrange, Definition.arrange]
        mockDataStore.saveDefinitionsResult = .failure(.genericError)
        
        do {
            try environment.saveDefinitions(expectedDefinitions)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.saveDefinitionsSpy == expectedDefinitions)
            #expect(mockDataStore.saveDefinitionsCalled == true)
        }
    }
    
    @Test
    func deleteDefinition_success() throws {
        let expectedId = UUID()
        
        try environment.deleteDefinition(with: expectedId)
        
        #expect(mockDataStore.deleteDefinitionSpy == expectedId)
        #expect(mockDataStore.deleteDefinitionCalled == true)
    }
    
    @Test
    func deleteDefinition_error() throws {
        let expectedId = UUID()
        mockDataStore.deleteDefinitionResult = .failure(.genericError)
        
        do {
            try environment.deleteDefinition(with: expectedId)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.deleteDefinitionSpy == expectedId)
            #expect(mockDataStore.deleteDefinitionCalled == true)
        }
    }
    
    @Test
    func saveSentenceAudio_success() throws {
        let expectedData = Data("test audio".utf8)
        let expectedId = UUID()
        
        try environment.saveSentenceAudio(expectedData, id: expectedId)
        
        #expect(mockDataStore.saveSentenceAudioDataSpy == expectedData)
        #expect(mockDataStore.saveSentenceAudioIdSpy == expectedId)
        #expect(mockDataStore.saveSentenceAudioCalled == true)
    }
    
    @Test
    func saveSentenceAudio_error() throws {
        let expectedData = Data("test audio".utf8)
        let expectedId = UUID()
        mockDataStore.saveSentenceAudioResult = .failure(.genericError)
        
        do {
            try environment.saveSentenceAudio(expectedData, id: expectedId)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.saveSentenceAudioDataSpy == expectedData)
            #expect(mockDataStore.saveSentenceAudioIdSpy == expectedId)
            #expect(mockDataStore.saveSentenceAudioCalled == true)
        }
    }
    
    @Test
    func playSound() throws {
        let sound = AppSound.actionButtonPress
        
        environment.playSound(sound)
        
        #expect(mockAudioEnvironment.playSoundSpy == sound)
        #expect(mockAudioEnvironment.playSoundCalled == true)
    }
    
    @Test
    func loadDefinitions_success() throws {
        let expectedDefinitions = [Definition.arrange, Definition.arrange]
        mockDataStore.loadDefinitionsResult = .success(expectedDefinitions)
        
        let result = try environment.loadDefinitions()
        
        #expect(result == expectedDefinitions)
        #expect(mockDataStore.loadDefinitionsCalled == true)
        #expect(environment.definitionsSubject.value == expectedDefinitions)
    }
    
    @Test
    func loadDefinitions_error() throws {
        mockDataStore.loadDefinitionsResult = .failure(.genericError)
        
        do {
            _ = try environment.loadDefinitions()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.loadDefinitionsCalled == true)
            #expect(environment.definitionsSubject.value == nil)
        }
    }
    
    @Test
    func cleanupDefinitionsNotInChapters_success() throws {
        let expectedChapters = [Chapter.arrange, Chapter.arrange]
        
        try environment.cleanupDefinitionsNotInChapters(expectedChapters)
        
        #expect(mockDataStore.cleanupDefinitionsNotInChaptersSpy == expectedChapters)
        #expect(mockDataStore.cleanupDefinitionsNotInChaptersCalled == true)
    }
    
    @Test
    func cleanupDefinitionsNotInChapters_error() throws {
        let expectedChapters = [Chapter.arrange, Chapter.arrange]
        mockDataStore.cleanupDefinitionsNotInChaptersResult = .failure(.genericError)
        
        do {
            try environment.cleanupDefinitionsNotInChapters(expectedChapters)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.cleanupDefinitionsNotInChaptersSpy == expectedChapters)
            #expect(mockDataStore.cleanupDefinitionsNotInChaptersCalled == true)
        }
    }
    
    @Test
    func cleanupOrphanedSentenceAudioFiles_success() throws {
        try environment.cleanupOrphanedSentenceAudioFiles()
        
        #expect(mockDataStore.cleanupOrphanedSentenceAudioFilesCalled == true)
    }
    
    @Test
    func cleanupOrphanedSentenceAudioFiles_error() throws {
        mockDataStore.cleanupOrphanedSentenceAudioFilesResult = .failure(.genericError)
        
        do {
            try environment.cleanupOrphanedSentenceAudioFiles()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockDataStore.cleanupOrphanedSentenceAudioFilesCalled == true)
        }
    }
    
    @Test
    func settingsUpdatedSubject_passThrough() throws {
        let expectedSettings = SettingsState.arrange
        mockSettingsEnvironment.settingsUpdatedSubject.send(expectedSettings)
        
        #expect(environment.settingsUpdatedSubject.value == expectedSettings)
    }
}
