//
//  MockStudyEnvironment.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Audio
import Combine
import Foundation
import Settings
import Study
import TextGeneration

enum MockStudyEnvironmentError: Error {
    case genericError
}

public class MockStudyEnvironment: StudyEnvironmentProtocol {
    
    public var definitionsSubject: CurrentValueSubject<[Definition]?, Never>
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    
    public init(
        definitionsSubject: CurrentValueSubject<[Definition]?, Never> = .init(nil),
        settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> = .init(nil)
    ) {
        self.definitionsSubject = definitionsSubject
        self.settingsUpdatedSubject = settingsUpdatedSubject
    }
    
    var loadSentenceAudioSpy: UUID?
    var loadSentenceAudioCalled = false
    var loadSentenceAudioResult: Result<Data, MockStudyEnvironmentError> = .success(Data())
    public func loadSentenceAudio(id: UUID) throws -> Data {
        loadSentenceAudioSpy = id
        loadSentenceAudioCalled = true
        switch loadSentenceAudioResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var deleteDefinitionSpy: UUID?
    var deleteDefinitionCalled = false
    var deleteDefinitionResult: Result<Void, MockStudyEnvironmentError> = .success(())
    public func deleteDefinition(with id: UUID) throws {
        deleteDefinitionSpy = id
        deleteDefinitionCalled = true
        switch deleteDefinitionResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var playSoundSpy: AppSound?
    var playSoundCalled = false
    public func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
    }
    
    var saveDefinitionsSpy: [Definition]?
    var saveDefinitionsCalled = false
    var saveDefinitionsResult: Result<Void, MockStudyEnvironmentError> = .success(())
    public func saveDefinitions(_ definitions: [Definition]) throws {
        saveDefinitionsSpy = definitions
        saveDefinitionsCalled = true
        switch saveDefinitionsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveSentenceAudioAudioDataSpy: Data?
    var saveSentenceAudioIdSpy: UUID?
    var saveSentenceAudioCalled = false
    var saveSentenceAudioResult: Result<Void, MockStudyEnvironmentError> = .success(())
    public func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        saveSentenceAudioAudioDataSpy = audioData
        saveSentenceAudioIdSpy = id
        saveSentenceAudioCalled = true
        switch saveSentenceAudioResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var fetchDefinitionsSentenceSpy: Sentence?
    var fetchDefinitionsChapterSpy: Chapter?
    var fetchDefinitionsDeviceLanguageSpy: Language?
    var fetchDefinitionsCalled = false
    var fetchDefinitionsResult: Result<[Definition], MockStudyEnvironmentError> = .success([])
    public func fetchDefinitions(
        in sentence: Sentence?,
        chapter: Chapter,
        deviceLanguage: Language
    ) async throws -> [Definition] {
        fetchDefinitionsSentenceSpy = sentence
        fetchDefinitionsChapterSpy = chapter
        fetchDefinitionsDeviceLanguageSpy = deviceLanguage
        fetchDefinitionsCalled = true
        switch fetchDefinitionsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var loadDefinitionsCalled = false
    var loadDefinitionsResult: Result<[Definition], MockStudyEnvironmentError> = .success([])
    public func loadDefinitions() throws -> [Definition] {
        loadDefinitionsCalled = true
        switch loadDefinitionsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var cleanupDefinitionsNotInChaptersSpy: [Chapter]?
    var cleanupDefinitionsNotInChaptersCalled = false
    var cleanupDefinitionsNotInChaptersResult: Result<Void, MockStudyEnvironmentError> = .success(())
    public func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws {
        cleanupDefinitionsNotInChaptersSpy = chapters
        cleanupDefinitionsNotInChaptersCalled = true
        switch cleanupDefinitionsNotInChaptersResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var cleanupOrphanedSentenceAudioFilesCalled = false
    var cleanupOrphanedSentenceAudioFilesResult: Result<Void, MockStudyEnvironmentError> = .success(())
    public func cleanupOrphanedSentenceAudioFiles() throws {
        cleanupOrphanedSentenceAudioFilesCalled = true
        switch cleanupOrphanedSentenceAudioFilesResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}