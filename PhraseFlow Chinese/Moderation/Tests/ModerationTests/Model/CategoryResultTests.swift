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
        let categoryResult = CategoryResult.arrange(
            threshold: threshold,
            score: passingScore
        )
        #expect(categoryResult.didPass == true)
    }
    
    @Test
    func didPass_false() {
        let categoryResult = CategoryResult.arrange(
            threshold: threshold,
            score: failingScore
        )
        #expect(categoryResult.didPass == false)
    }
    
    @Test
    func thresholdPercentageString() {
        let categoryResult = CategoryResult.arrange(
            threshold: threshold
        )
        #expect(categoryResult.thresholdPercentageString == "\(Int(threshold * 100))%")
    }
    
    @Test
    func scorePercentageString() {
        let categoryResult = CategoryResult.arrange(
            score: passingScore
        )
        #expect(categoryResult.scorePercentageString == "\(Int(passingScore * 100))%")
    }
}
