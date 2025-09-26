//
//  OpenRouterModel.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

public enum OpenRouterModel {
    case metaLlama, geminiFlash, grok4Fast, gpt_4o_Mini

    static var baseUrl: String {
        "https://openrouter.ai/api/v1/chat/completions"
    }

    var modelName: String {
        switch self {
        case .metaLlama:
            return "meta-llama/llama-3.3-70b-instruct"
        case .geminiFlash:
            return "google/gemini-2.5-flash-lite"
        case .grok4Fast:
            return "x-ai/grok-4-fast:free"
        case .gpt_4o_Mini:
            return "gpt-4o-mini-2024-07-18"
        }
    }
}
