//
//  ModerationResult.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

struct ModerationResult: Codable {
    let flagged: Bool
    let categories: [String: Bool]
    let category_scores: [String: Double]
    let category_applied_input_types: [String: [String]]
}
