//
//  MockTranslationDataStore.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Combine
import Foundation
import TextGeneration
import TextGenerationMocks
import Translation

enum MockTranslationDataStoreError: Error {
    case genericError
}

public class MockTranslationDataStore: TranslationDataStoreProtocol {
    
    public init() {
        
    }
    
    var saveTranslationSpy: Chapter?
    var saveTranslationCalled = false
    var saveTranslationResult: Result<Void, MockTranslationDataStoreError> = .success(())
    public func saveTranslation(_ chapter: Chapter) throws {
        saveTranslationSpy = chapter
        saveTranslationCalled = true
        switch saveTranslationResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var loadTranslationHistoryCalled = false
    var loadTranslationHistoryResult: Result<[Chapter], MockTranslationDataStoreError> = .success([.arrange])
    public func loadTranslationHistory() throws -> [Chapter] {
        loadTranslationHistoryCalled = true
        switch loadTranslationHistoryResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var deleteTranslationIdSpy: UUID?
    var deleteTranslationCalled = false
    var deleteTranslationResult: Result<Void, MockTranslationDataStoreError> = .success(())
    public func deleteTranslation(id: UUID) throws {
        deleteTranslationIdSpy = id
        deleteTranslationCalled = true
        switch deleteTranslationResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var cleanupOrphanedTranslationFilesCalled = false
    var cleanupOrphanedTranslationFilesResult: Result<Void, MockTranslationDataStoreError> = .success(())
    public func cleanupOrphanedTranslationFiles() throws {
        cleanupOrphanedTranslationFilesCalled = true
        switch cleanupOrphanedTranslationFilesResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}