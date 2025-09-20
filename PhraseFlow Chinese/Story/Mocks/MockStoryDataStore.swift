//
//  MockStoryDataStore.swift
//  Story
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Story
import TextGeneration

enum MockStoryDataStoreError: Error {
    case genericError
}

public class MockStoryDataStore: StoryDataStoreProtocol {
    
    public init() {}
    
    var saveChapterSpy: Chapter?
    var saveChapterCalled = false
    var saveChapterResult: Result<Void, MockStoryDataStoreError> = .success(())
    
    public func saveChapter(_ chapter: Chapter) throws {
        saveChapterSpy = chapter
        saveChapterCalled = true
        
        switch saveChapterResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }
    
    var loadAllChaptersCalled = false
    var loadAllChaptersResult: Result<[Chapter], MockStoryDataStoreError> = .success([])
    
    public func loadAllChapters() throws -> [Chapter] {
        loadAllChaptersCalled = true
        
        switch loadAllChaptersResult {
        case .success(let chapters):
            return chapters
        case .failure(let error):
            throw error
        }
    }
    
    var deleteChapterSpy: Chapter?
    var deleteChapterCalled = false
    var deleteChapterResult: Result<Void, MockStoryDataStoreError> = .success(())
    
    public func deleteChapter(_ chapter: Chapter) throws {
        deleteChapterSpy = chapter
        deleteChapterCalled = true
        
        switch deleteChapterResult {
        case .success():
            return
        case .failure(let error):
            throw error
        }
    }
    
    var loadAllChaptersForStoryIdSpy: UUID?
    var loadAllChaptersForStoryIdCalled = false
    var loadAllChaptersForStoryIdResult: Result<[Chapter], MockStoryDataStoreError> = .success([])
    
    public func loadAllChapters(for storyId: UUID) throws -> [Chapter] {
        loadAllChaptersForStoryIdSpy = storyId
        loadAllChaptersForStoryIdCalled = true
        
        switch loadAllChaptersForStoryIdResult {
        case .success(let chapters):
            return chapters
        case .failure(let error):
            throw error
        }
    }
}