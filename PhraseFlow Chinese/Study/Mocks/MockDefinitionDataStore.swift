//
//  MockDefinitionDataStore.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Combine
import Foundation
import Study
import TextGeneration

enum MockDefinitionDataStoreError: Error {
    case genericError
}

public class MockDefinitionDataStore: DefinitionDataStoreProtocol {
    
    public init() {}
    
    var loadDefinitionsCalled = false
    var loadDefinitionsResult: Result<[Definition], MockDefinitionDataStoreError> = .success([])
    
    public func loadDefinitions() throws -> [Definition] {
        loadDefinitionsCalled = true
        switch loadDefinitionsResult {
        case .success(let definitions):
            return definitions
        case .failure(let error):
            throw error
        }
    }
    
    var saveDefinitionsSpy: [Definition]?
    var saveDefinitionsCalled = false
    var saveDefinitionsResult: Result<Void, MockDefinitionDataStoreError> = .success(())
    
    public func saveDefinitions(_ definitions: [Definition]) throws {
        saveDefinitionsSpy = definitions
        saveDefinitionsCalled = true
        switch saveDefinitionsResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    var deleteDefinitionSpy: UUID?
    var deleteDefinitionCalled = false
    var deleteDefinitionResult: Result<Void, MockDefinitionDataStoreError> = .success(())
    
    public func deleteDefinition(with id: UUID) throws {
        deleteDefinitionSpy = id
        deleteDefinitionCalled = true
        switch deleteDefinitionResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    var cleanupDefinitionsNotInChaptersSpy: [Chapter]?
    var cleanupDefinitionsNotInChaptersCalled = false
    var cleanupDefinitionsNotInChaptersResult: Result<Void, MockDefinitionDataStoreError> = .success(())
    
    public func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws {
        cleanupDefinitionsNotInChaptersSpy = chapters
        cleanupDefinitionsNotInChaptersCalled = true
        switch cleanupDefinitionsNotInChaptersResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    var saveSentenceAudioDataSpy: Data?
    var saveSentenceAudioIdSpy: UUID?
    var saveSentenceAudioCalled = false
    var saveSentenceAudioResult: Result<Void, MockDefinitionDataStoreError> = .success(())
    
    public func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        saveSentenceAudioDataSpy = audioData
        saveSentenceAudioIdSpy = id
        saveSentenceAudioCalled = true
        switch saveSentenceAudioResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    var loadSentenceAudioSpy: UUID?
    var loadSentenceAudioCalled = false
    var loadSentenceAudioResult: Result<Data, MockDefinitionDataStoreError> = .success(Data())
    
    public func loadSentenceAudio(id: UUID) throws -> Data {
        loadSentenceAudioSpy = id
        loadSentenceAudioCalled = true
        switch loadSentenceAudioResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    var cleanupOrphanedSentenceAudioFilesCalled = false
    var cleanupOrphanedSentenceAudioFilesResult: Result<Void, MockDefinitionDataStoreError> = .success(())
    
    public func cleanupOrphanedSentenceAudioFiles() throws {
        cleanupOrphanedSentenceAudioFilesCalled = true
        switch cleanupOrphanedSentenceAudioFilesResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}