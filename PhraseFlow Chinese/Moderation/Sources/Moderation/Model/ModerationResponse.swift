//
//  ModerationResponse.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

public struct ModerationResponse: Codable {
    let id: String
    let model: String
    let results: [ModerationResult]

    var didPassModeration: Bool {
        guard let firstResult = results.first else {
            return true
        }
        for category in ModerationCategories.allCases {
            let score = firstResult.category_scores[category.key] ?? 0.0
            if score >= category.thresholdScore {
                return false
            }
        }
        return true
    }

    var categoryResults: [CategoryResult] {
        guard let firstResult = results.first else {
            return []
        }

        return ModerationCategories.allCases.map { category in
            let score = firstResult.category_scores[category.key] ?? 0.0
            return CategoryResult(
                category: category,
                threshold: category.thresholdScore,
                score: score
            )
        }
    }
}
