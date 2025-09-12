//
//  SubscriptionLevel.swift
//  FlowTale
//
//  Created by Claude on 26/07/2025.
//

import Foundation

public enum SubscriptionLevel: CaseIterable, Sendable, Equatable, Codable {
    case level1, level2

    public var ssmlCharacterLimitPerDay: Int {
        switch self {
        case .level1:
            15000
        case .level2:
            30000
        }
    }
    
    public var idString: String {
        switch self {
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
