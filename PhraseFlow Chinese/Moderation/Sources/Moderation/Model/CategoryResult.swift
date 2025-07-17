//
//  CategoryResult.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import Foundation

struct CategoryResult: Identifiable {
    let id = UUID()

    let category: ModerationCategories
    let threshold: Double
    let score: Double

    /// Did this particular category pass (score < threshold)?
    var didPass: Bool {
        score < threshold
    }

    /// For easy display in the UI: "80%" or "92%" etc.
    var thresholdPercentageString: String {
        "\(Int(threshold * 100))%"
    }

    var scorePercentageString: String {
        "\(Int(score * 100))%"
    }
}
