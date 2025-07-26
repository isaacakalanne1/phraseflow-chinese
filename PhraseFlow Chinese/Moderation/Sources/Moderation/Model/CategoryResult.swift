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
