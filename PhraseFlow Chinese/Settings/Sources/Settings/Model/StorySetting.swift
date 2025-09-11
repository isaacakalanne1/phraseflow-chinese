//
//  StorySetting.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation
import UIKit

public enum StorySetting: Codable, Equatable, Sendable {
    case random, customPrompt(String)

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
    
    var thumbnail: UIImage? {
        switch self {
        case .random:
            return UIImage(named: "StoryPrompt-Random")
        case .customPrompt:
            return UIImage(named: "StoryPrompt-Create")
        }
    }
}
