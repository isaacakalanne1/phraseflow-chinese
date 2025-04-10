//
//  ModerationCategories.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

enum ModerationCategories: CaseIterable {
    case sexual
    case sexualMinors
    case violenceGraphic
    case selfHarmIntent
    case selfHarmInstructions
    case illicitViolent

    /// Human-readable name you want to display in the UI
    var name: String {
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
    var key: String {
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
    var thresholdScore: Double {
        switch self {
        case .sexual:
            return 0.8
        case .sexualMinors:
            return 0.2
        case .violenceGraphic:
            return 0.7
        case .selfHarmIntent:
            return 0.2
        case .selfHarmInstructions:
            return 0.2
        case .illicitViolent:
            return 0.2
        }
    }
}
