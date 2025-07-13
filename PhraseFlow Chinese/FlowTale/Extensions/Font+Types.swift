//
//  Font+Types.swift
//  FlowTale
//
//  Created by iakalann on 13/07/2025.
//

import SwiftUI

extension Font {

    // MARK: Header

    static func flowTaleHeader() -> Font {
        .title2
    }

    static func flowTaleSecondaryHeader() -> Font {
        .subheadline
    }

    static func flowTaleSubHeader() -> Font {
        .footnote
    }

    // MARK: Body

    static func flowTaleBodyXSmall() -> Font {
        .system(size: 12, weight: .light)
    }

    static func flowTaleBodySmall() -> Font {
        .system(size: 16, weight: .light)
    }

    static func flowTaleBodyMedium() -> Font {
        .system(size: 20, weight: .light)
    }

    static func flowTaleBodyLarge() -> Font {
        .system(size: 30, weight: .light)
    }

    static func flowTaleBodyXLarge() -> Font {
        .system(size: 60, weight: .light)
    }
}
