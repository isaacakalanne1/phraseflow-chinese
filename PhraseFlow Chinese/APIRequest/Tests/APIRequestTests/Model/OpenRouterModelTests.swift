//
//  OpenRouterModelTests.swift
//  APIRequest
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import APIRequest

class OpenRouterModelTests {
    
    @Test
    func staticProperties() {
        #expect(OpenRouterModel.baseUrl == "https://openrouter.ai/api/v1/chat/completions")
        #expect(OpenRouterModel.authKey == "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")
    }
    
    @Test
    func metaLlama() {
        let model = OpenRouterModel.metaLlama
        #expect(model.modelName == "meta-llama/llama-3.3-70b-instruct")
    }
    
    @Test
    func geminiFlash() {
        let model = OpenRouterModel.geminiFlash
        #expect(model.modelName == "google/gemini-2.5-flash-lite")
    }
    
    @Test
    func gpt4oMini() {
        let model = OpenRouterModel.gpt_4o_Mini
        #expect(model.modelName == "gpt-4o-mini-2024-07-18")
    }
}

