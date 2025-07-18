//
//  FTFont.swift
//  FlowTale
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI

public struct FTFont {

    // MARK: Header

    public static func flowTaleHeader() -> Font {
        .title2
    }

    public static func flowTaleSecondaryHeader() -> Font {
        .subheadline
    }

    public static func flowTaleSubHeader() -> Font {
        .footnote
    }

    // MARK: Body

    public static func flowTaleBodyXSmall() -> Font {
        .system(size: 12, weight: .light)
    }

    public static func flowTaleBodySmall() -> Font {
        .system(size: 16, weight: .light)
    }

    public static func flowTaleBodyMedium() -> Font {
        .system(size: 20, weight: .light)
    }

    public static func flowTaleBodyLarge() -> Font {
        .system(size: 30, weight: .light)
    }

    public static func flowTaleBodyXLarge() -> Font {
        .system(size: 60, weight: .light)
    }
}
