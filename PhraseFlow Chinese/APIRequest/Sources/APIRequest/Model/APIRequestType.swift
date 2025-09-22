//
//  APIRequestType.swift
//  FlowTale
//
//  Created by iakalann on 13/12/2024.
//

import Foundation

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

    // TODO: Don't store in plain-text, fetch from Firebase
    public var authKey: String {
        switch self {
        case .openAI:
            "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"
        case .openRouter:
            OpenRouterModel.authKey
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
