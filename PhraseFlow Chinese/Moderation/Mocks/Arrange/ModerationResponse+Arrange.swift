//
//  ModerationResponse+Arrange.swift
//  Moderation
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Moderation

public extension ModerationResponse {
    static var arrange: ModerationResponse {
        .arrange()
    }

    static func arrange(
        results: [ModerationResult] = []
    ) -> ModerationResponse {
        .init(results: results)
    }
}
