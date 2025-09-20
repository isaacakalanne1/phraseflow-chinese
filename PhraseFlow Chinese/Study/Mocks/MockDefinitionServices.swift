//
//  MockDefinitionServices.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Settings
import Study
import TextGeneration

enum MockDefinitionServicesError: Error {
    case genericError
}

public class MockDefinitionServices: DefinitionServicesProtocol {
    
    public init() {}
    
    var fetchDefinitionsSentenceSpy: Sentence?
    var fetchDefinitionsChapterSpy: Chapter?
    var fetchDefinitionsDeviceLanguageSpy: Language?
    var fetchDefinitionsCalled = false
    var fetchDefinitionsResult: Result<[Definition], MockDefinitionServicesError> = .success([])
    
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
        case .success(let definitions):
            return definitions
        case .failure(let error):
            throw error
        }
    }
}