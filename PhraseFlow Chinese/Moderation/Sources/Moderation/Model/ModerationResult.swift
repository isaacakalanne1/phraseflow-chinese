//
//  ModerationResult.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

public struct ModerationResult: Codable, Equatable, Sendable {
    let flagged: Bool
    let category_scores: [String: Double]
    
    public init(
        flagged: Bool,
        category_scores: [String : Double]
    ) {
        self.flagged = flagged
        self.category_scores = category_scores
    }
}
