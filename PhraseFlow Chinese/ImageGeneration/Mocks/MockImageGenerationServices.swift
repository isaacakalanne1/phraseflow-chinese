//
//  MockImageGenerationServices.swift
//  ImageGeneration
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import ImageGeneration

enum MockImageGenerationServicesError: Error {
    case genericError
}

public class MockImageGenerationServices: ImageGenerationServicesProtocol {
    
    public init() {}
    
    var generateImagePromptSpy: String?
    var generateImageCalled = false
    var generateImageResult: Result<Data, MockImageGenerationServicesError> = .success(Data("mock image data".utf8))
    
    public func generateImage(with prompt: String) async throws -> Data {
        generateImagePromptSpy = prompt
        generateImageCalled = true
        
        switch generateImageResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}