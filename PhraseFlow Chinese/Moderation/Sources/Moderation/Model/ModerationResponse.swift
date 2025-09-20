//
//  ModerationResponse.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

public struct ModerationResponse: Codable, Equatable, Sendable {
    let results: [ModerationResult]
    
    public init(
        results: [ModerationResult]
    ) {
        self.results = results
    }

    public var didPassModeration: Bool {
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

    public var categoryResults: [CategoryResult] {
        guard let firstResult = results.first else {
            return []
        }

        return ModerationCategories.allCases.map {
            return CategoryResult(
                category: $0,
                threshold: $0.thresholdScore,
                score: firstResult.category_scores[$0.key] ?? 0.0
            )
        }
    }
}
