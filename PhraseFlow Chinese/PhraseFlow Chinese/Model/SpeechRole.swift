//
//  SpeechRole.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/11/2024.
//

import Foundation

enum SpeechRole: String, Codable, CaseIterable {
    case girl, boy, _default, youngAdultFemale, youngAdultMale, olderAdultFemale, olderAdultMale, seniorFemale, seniorMale

    init?(rawValue: String) {
        if let value = SpeechRole.allCases.first(where: { $0.ssmlName == rawValue }) {
            self = value
        }
        self = .girl
    }

    var ssmlName: String {
        switch self {
        case .girl,
                .boy:
            return self.rawValue.capitalized
        case ._default:
            return "Default"
        case .youngAdultFemale:
            return "YoungAdultFemale"
        case .youngAdultMale:
            return "YoungAdultMale"
        case .olderAdultFemale:
            return "OlderAdultFemale"
        case .olderAdultMale:
            return "OlderAdultMale"
        case .seniorFemale:
            return "SeniorFemale"
        case .seniorMale:
            return "SeniorMale"
        }
    }
}
