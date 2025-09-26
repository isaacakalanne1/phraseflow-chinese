//
//  APIRequestTypeTests.swift
//  APIRequest
//
//  Created by Isaac Akalanne on 22/09/2025.
//

import Testing
@testable import APIRequest

class APIRequestTypeTests {
    
    @Test
    func openAI() {
        let requestType = APIRequestType.openAI
        #expect(requestType.baseUrl == "https://api.openai.com/v1/chat/completions")
        #expect(requestType.modelName == "gpt-4o-mini")
    }
    
    @Test
    func openRouter_metaLlama() {
        let requestType = APIRequestType.openRouter(.metaLlama)
        #expect(requestType.baseUrl == "https://openrouter.ai/api/v1/chat/completions")
        #expect(requestType.modelName == "meta-llama/llama-3.3-70b-instruct")
    }
    
    @Test
    func openRouter_geminiFlash() {
        let requestType = APIRequestType.openRouter(.geminiFlash)
        #expect(requestType.baseUrl == "https://openrouter.ai/api/v1/chat/completions")
        #expect(requestType.modelName == "google/gemini-2.5-flash-lite")
    }
    
    @Test
    func openRouter_gpt4oMini() {
        let requestType = APIRequestType.openRouter(.gpt_4o_Mini)
        #expect(requestType.baseUrl == "https://openrouter.ai/api/v1/chat/completions")
        #expect(requestType.modelName == "gpt-4o-mini-2024-07-18")
    }
}
