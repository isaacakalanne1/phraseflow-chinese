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

// MARK: - Font Extensions
extension Font {
    // MARK: Header
    public static func flowTaleHeader() -> Font {
        FTFont.flowTaleHeader()
    }
    
    public static func flowTaleSecondaryHeader() -> Font {
        FTFont.flowTaleSecondaryHeader()
    }
    
    public static func flowTaleSubHeader() -> Font {
        FTFont.flowTaleSubHeader()
    }
    
    // MARK: Body
    public static func flowTaleBodyXSmall() -> Font {
        FTFont.flowTaleBodyXSmall()
    }
    
    public static func flowTaleBodySmall() -> Font {
        FTFont.flowTaleBodySmall()
    }
    
    public static func flowTaleBodyMedium() -> Font {
        FTFont.flowTaleBodyMedium()
    }
    
    public static func flowTaleBodyLarge() -> Font {
        FTFont.flowTaleBodyLarge()
    }
    
    public static func flowTaleBodyXLarge() -> Font {
        FTFont.flowTaleBodyXLarge()
    }
}
