//
//  FTFont.swift
//  FlowTale
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI

public enum FTFont {
    case header,
         secondaryHeader,
         subHeader,
         bodyXSmall,
         bodySmall,
         bodyMedium,
         bodyLarge,
         bodyXLarge
    
    public var font: Font {
        .system(size: fontSize, weight: fontWeight)
    }
    
    var fontSize: CGFloat {
        switch self {
        case .header:
            25
        case .secondaryHeader:
            20
        case .subHeader:
            12
        case .bodyXSmall:
            12
        case .bodySmall:
            16
        case .bodyMedium:
            20
        case .bodyLarge:
            30
        case .bodyXLarge:
            60
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .header,
                .secondaryHeader,
                .subHeader:
            return .medium
        case .bodyXSmall,
                .bodySmall,
                .bodyMedium,
                .bodyLarge,
                .bodyXLarge:
            return .light
        }
    }
}
