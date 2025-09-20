//
//  CategoryResult+Arrange.swift
//  Moderation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Moderation

public extension CategoryResult {
    static var arrange: CategoryResult {
        .arrange()
    }
    
    static func arrange(
        category: ModerationCategories = .illicitViolent,
        threshold: Double = 0,
        score: Double = 0
    ) -> CategoryResult {
        .init(
            category: category,
            threshold: threshold,
            score: score
        )
    }
}
