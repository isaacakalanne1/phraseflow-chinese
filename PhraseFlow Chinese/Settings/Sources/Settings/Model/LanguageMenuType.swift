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
    
    var shouldShowAutoDetect: Bool {
        switch self {
        case .normal,
                .translationTargetLanguage:
            return false
        case .translationSourceLanguage:
            return true
        }
    }
}
