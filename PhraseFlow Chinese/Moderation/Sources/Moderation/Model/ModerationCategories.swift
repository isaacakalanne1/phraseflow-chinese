//
//  ModerationCategories.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import Localization

public enum ModerationCategories: CaseIterable, Sendable {
    case sexual
    case sexualMinors
    case violenceGraphic
    case selfHarmIntent
    case selfHarmInstructions
    case illicitViolent

    /// Human-readable name you want to display in the UI
    public var name: String {
        switch self {
        case .sexual:
            return LocalizedString.moderationCategorySexual
        case .sexualMinors:
            return LocalizedString.moderationCategorySexualMinors
        case .violenceGraphic:
            return LocalizedString.moderationCategoryViolenceGraphic
        case .selfHarmIntent:
            return LocalizedString.moderationCategorySelfHarmIntent
        case .selfHarmInstructions:
            return LocalizedString.moderationCategorySelfHarmInstructions
        case .illicitViolent:
            return LocalizedString.moderationCategoryIllicitViolence
        }
    }

    /// Key to use when looking up the category_scores dictionary from the API
    public var key: String {
        switch self {
        case .sexual:
            return "sexual"
        case .sexualMinors:
            return "sexual/minors"
        case .violenceGraphic:
            return "violence/graphic"
        case .selfHarmIntent:
            return "self-harm/intent"
        case .selfHarmInstructions:
            return "self-harm/instructions"
        case .illicitViolent:
            return "illicit/violent"
        }
    }

    /// The threshold above which the story fails moderation
    public var thresholdScore: Double {
        switch self {
        case .sexual:
            return 0.2
        case .sexualMinors:
            return 0.2
        case .violenceGraphic:
            return 0.2
        case .selfHarmIntent:
            return 0.2
        case .selfHarmInstructions:
            return 0.2
        case .illicitViolent:
            return 0.2
        }
    }
}
