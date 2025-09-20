//
//  ModerationResponseTests.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
import Localization
@testable import Moderation
@testable import ModerationMocks

class ModerationResponseTests {

    @Test
    func emptyResults() {
        let response = ModerationResponse.arrange
        #expect(response.didPassModeration == true)
        #expect(response.categoryResults.isEmpty == true)
    }

    @Test
    func passingResult() {
        let category = ModerationCategories.illicitViolent
        let score: Double = 0
        let moderationResult: ModerationResult = .arrange(
            category_scores: [category.key : score]
        )
        let expectedResults = ModerationCategories.allCases.map {
            return CategoryResult(
                category: $0,
                threshold: $0.thresholdScore,
                score: moderationResult.category_scores[$0.key] ?? 0.0
            )
        }
        let response = ModerationResponse.arrange(
            results: [moderationResult]
        )
        #expect(response.didPassModeration == true)
        #expect(response.categoryResults == expectedResults)
    }

    @Test
    func failingResult() {
        let category = ModerationCategories.illicitViolent
        let score: Double = 0.8
        let moderationResult: ModerationResult = .arrange(
            category_scores: [category.key : score]
        )
        let expectedResults = ModerationCategories.allCases.map {
            return CategoryResult(
                category: $0,
                threshold: $0.thresholdScore,
                score: moderationResult.category_scores[$0.key] ?? 0.0
            )
        }
        let response = ModerationResponse.arrange(
            results: [moderationResult]
        )
        #expect(response.didPassModeration == false)
        #expect(response.categoryResults == expectedResults)
    }
}
