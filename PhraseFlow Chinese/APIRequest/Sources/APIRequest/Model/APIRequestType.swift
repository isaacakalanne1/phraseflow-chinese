//
//  APIRequestType.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation
import FirebaseFirestore

public enum APIRequestType {
    case openAI, openRouter(OpenRouterModel)

    var baseUrl: String {
        switch self {
        case .openAI:
            "https://api.openai.com/v1/chat/completions"
        case .openRouter:
            OpenRouterModel.baseUrl
        }
    }

    public func authKey() async throws -> String {
        let db = Firestore.firestore()
        let document = try await db.collection("config").document("api_keys").getDocument()
        
        guard document.exists else {
            throw NSError(domain: "APIRequestType", code: 404, userInfo: [NSLocalizedDescriptionKey: "API keys document not found"])
        }
        
        switch self {
        case .openAI:
            guard let apiKey = document.data()?["openai_api_key"] as? String,
                  !apiKey.isEmpty else {
                throw NSError(domain: "APIRequestType", code: 401, userInfo: [NSLocalizedDescriptionKey: "OpenAI API key not found"])
            }
            return apiKey
        case .openRouter:
            guard let apiKey = document.data()?["openrouter_api_key"] as? String,
                  !apiKey.isEmpty else {
                throw NSError(domain: "APIRequestType", code: 401, userInfo: [NSLocalizedDescriptionKey: "OpenRouter API key not found"])
            }
            return apiKey
        }
    }

    var modelName: String {
        switch self {
        case .openAI:
            return "gpt-4o-mini"
        case let .openRouter(model):
            return model.modelName
        }
    }
}
