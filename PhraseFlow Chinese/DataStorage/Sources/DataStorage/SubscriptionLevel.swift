//
//  SubscriptionLevel.swift
//  FlowTale
//
//  Created by Claude on 26/07/2025.
//

import Foundation

public enum SubscriptionLevel: CaseIterable, Sendable, Equatable, Codable {
    case free, level1, level2, max

    public var ssmlCharacterLimitPerDay: Int {
        switch self {
        case .free:
            4000
        case .level1:
            15000
        case .level2:
            30000
        case .max:
            9_999_999_999
        }
    }
    
    public var idString: String {
        switch self {
        case .free,
                .max:
            ""
        case .level1:
            "com.flowtale.level_1"
        case .level2:
            "com.flowtale.level_2"
        }
    }

    public init?(id: String) {
        guard let level = SubscriptionLevel.allCases.first(where: { $0.idString == id }) else {
            return nil
        }
        self = level
    }
}
