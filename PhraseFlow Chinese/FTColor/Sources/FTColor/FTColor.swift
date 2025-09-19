// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public enum FTColor: String {
    case accent = "FTAccent"
    case background = "FTBackground"
    case error = "FTError"
    case highlight = "FTHighlight"
    case primary = "FTPrimary"
    case secondary = "FTSecondary"
    case wordHighlight = "FTWordHighlight"
    
    public var color: Color {
        Color(rawValue, bundle: .module)
    }
}
