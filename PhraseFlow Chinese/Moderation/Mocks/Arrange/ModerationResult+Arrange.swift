//
//  ModerationResponse+Arrange.swift
//  Moderation
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Moderation

public extension ModerationResult {
    static var arrange: ModerationResult {
        .arrange()
    }

    static func arrange(
        flagged: Bool = false,
        category_scores: [String : Double] = [:]
    ) -> ModerationResult {
        .init(
            flagged: flagged,
            category_scores: category_scores
        )
    }
}
