//
//  FlowTaleColorScheme.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import SwiftUI

enum FlowTaleColorScheme: Codable {
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
