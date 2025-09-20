//
//  CategoryResultTests.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Testing
@testable import Moderation
@testable import ModerationMocks

class CategoryResultTests {
    
    let threshold = 0.6
    let passingScore = 0.2
    let failingScore = 0.8
    
    @Test
    func didPass_true() {
        // Given
        let categoryResult = CategoryResult.arrange(
            threshold: threshold,
            score: passingScore
        )
        // When
        #expect(categoryResult.didPass == true)
    }
    
    @Test
    func didPass_false() {
        // Given
        let categoryResult = CategoryResult.arrange(
            threshold: threshold,
            score: failingScore
        )
        // When
        #expect(categoryResult.didPass == false)
    }
    
    @Test
    func thresholdPercentageString() {
        // Given
        let categoryResult = CategoryResult.arrange(
            threshold: threshold
        )
        // When
        #expect(categoryResult.thresholdPercentageString == "\(Int(threshold * 100))%")
    }
    
    @Test
    func scorePercentageString() {
        // Given
        let categoryResult = CategoryResult.arrange(
            score: passingScore
        )
        // When
        #expect(categoryResult.scorePercentageString == "\(Int(passingScore * 100))%")
    }
}
