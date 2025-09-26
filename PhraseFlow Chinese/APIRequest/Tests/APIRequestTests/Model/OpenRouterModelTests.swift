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

