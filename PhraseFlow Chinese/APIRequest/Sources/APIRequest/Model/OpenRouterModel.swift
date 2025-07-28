//
//  OpenRouterModel.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

public enum OpenRouterModel {
    case metaLlama, geminiFlash, gpt_4o_Mini

    static var baseUrl: String {
        "https://openrouter.ai/api/v1/chat/completions"
    }

    static var authKey: String {
        "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" // TODO: Don't store in plain-text, find recommended practice online, or use claude for recommended practice
    }

    var modelName: String {
        switch self {
        case .metaLlama:
            return "meta-llama/llama-3.3-70b-instruct"
        case .geminiFlash:
            return "google/gemini-2.5-flash-lite"
        case .gpt_4o_Mini:
            return "gpt-4o-mini-2024-07-18"
        }
    }
}
