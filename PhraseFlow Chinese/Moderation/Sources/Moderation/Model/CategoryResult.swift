//
//  CategoryResult.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import Foundation

public struct CategoryResult: Identifiable {
    public let id = UUID()

    let category: ModerationCategories
    let threshold: Double
    let score: Double
    
    public init(
        category: ModerationCategories,
        threshold: Double,
        score: Double
    ) {
        self.category = category
        self.threshold = threshold
        self.score = score
    }

    /// Did this particular category pass (score < threshold)?
    public var didPass: Bool {
        score < threshold
    }

    /// For easy display in the UI: "80%" or "92%" etc.
    public var thresholdPercentageString: String {
        "\(Int(threshold * 100))%"
    }

    public var scorePercentageString: String {
        "\(Int(score * 100))%"
    }
}

extension CategoryResult: Equatable {
    public static func == (lhs: CategoryResult, rhs: CategoryResult) -> Bool {
        return lhs.category == rhs.category &&
            lhs.threshold == rhs.threshold &&
            lhs.score == rhs.score
    }
}
