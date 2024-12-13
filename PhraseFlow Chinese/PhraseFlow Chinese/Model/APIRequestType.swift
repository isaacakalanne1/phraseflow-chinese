//
//  APIRequestType.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 13/12/2024.
//

import Foundation

enum APIRequestType {
    case openAI, openRouter

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
            "gpt-4o-mini-2024-07-18"
        case .openRouter:
            "meta-llama/llama-3.3-70b-instruct"
        }
    }
}
