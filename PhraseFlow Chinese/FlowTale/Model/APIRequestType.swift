//
//  APIRequestType.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation

enum OpenRouterModel {
    case metaLlama, geminiFlash
}

enum APIRequestType {
    case openAI, openRouter(OpenRouterModel)

    var baseUrl: String {
        switch self {
        case .openAI:
            "https://api.openai.com/v1/chat/completions"
        case .openRouter:
            "https://openrouter.ai/api/v1/chat/completions"
        }
    }

    var authKey: String {
        switch self {
        case .openAI:
            "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"
        case .openRouter:
            "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"
        }
    }

    var modelName: String {
        switch self {
        case .openAI:
            return "gpt-4o-mini"
        case .openRouter(let model):
            switch model {
            case .metaLlama:
                return "meta-llama/llama-3.3-70b-instruct"
            case .geminiFlash:
                return "google/gemini-flash-1.5-8b"
            }
//            "deepseek/deepseek-chat"
        }
    }
}
