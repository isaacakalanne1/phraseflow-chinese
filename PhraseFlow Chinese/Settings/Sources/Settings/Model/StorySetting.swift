//
//  StorySetting.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation

public enum StorySetting: Codable, Equatable, Sendable {
    case random, customPrompt(String)

    var emoji: String {
        switch self {
        case .random:
            return "🎲"
        case .customPrompt:
            return "✏️"
        }
    }

    var title: String {
        switch self {
        case .random:
            return "Random story"
        case .customPrompt(let prompt):
            return "Custom story (\(prompt))"
        }
    }

    public var prompt: String? {
        switch self {
        case .random:
            return nil
        case .customPrompt(let prompt):
            return prompt
        }
    }
}
