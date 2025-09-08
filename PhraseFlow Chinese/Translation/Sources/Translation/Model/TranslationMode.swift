//
//  TranslationMode.swift
//  Translation
//
//  Created by Isaac Akalanne on 26/07/2025.
//

import Localization

public enum TranslationMode: String, CaseIterable, Sendable {
    case translate
    case breakdown
    
    public var displayName: String {
        switch self {
        case .translate:
            return LocalizedString.translate
        case .breakdown:
            return LocalizedString.breakdown
        }
    }
}
