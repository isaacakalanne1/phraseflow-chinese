//
//  MockTranslationServices.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Settings
import TextGeneration
import TextGenerationMocks
import Translation

enum MockTranslationServicesError: Error {
    case genericError
}

public class MockTranslationServices: TranslationServicesProtocol {
    
    public init() {
        
    }
    
    var translateTextTextSpy: String?
    var translateTextSourceLanguageSpy: Language?
    var translateTextTargetLanguageSpy: Language?
    var translateTextCalled = false
    var translateTextResult: Result<Chapter, MockTranslationServicesError> = .success(.arrange)
    public func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter {
        translateTextTextSpy = text
        translateTextSourceLanguageSpy = sourceLanguage
        translateTextTargetLanguageSpy = targetLanguage
        translateTextCalled = true
        switch translateTextResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
}