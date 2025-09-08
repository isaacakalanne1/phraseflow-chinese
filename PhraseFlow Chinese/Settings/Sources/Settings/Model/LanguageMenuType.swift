//
//  LanguageMenuType.swift
//  FlowTale
//
//  Created by iakalann on 20/06/2025.
//

public enum LanguageMenuType {
    case normal
    case translationSourceLanguage
    case translationTargetLanguage
    case translationTextLanguage
    
    var shouldShowAutoDetect: Bool {
        switch self {
        case .normal,
                .translationTextLanguage:
            return false
        case .translationSourceLanguage,
                .translationTargetLanguage:
            return true
        }
    }
}
