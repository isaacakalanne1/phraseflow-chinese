//
//  FlowTaleColorScheme.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

public enum FlowTaleColorScheme: Codable, Sendable {
    case light, dark

    var colorScheme: ColorScheme {
        switch self {
        case .light:
                .light
        case .dark:
                .dark
        }
    }
}
