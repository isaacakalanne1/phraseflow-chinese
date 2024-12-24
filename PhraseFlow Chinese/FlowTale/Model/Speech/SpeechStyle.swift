//
//  SpeechStyle.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 06/11/2024.
//

import Foundation

enum SpeechStyle: String, Codable, CaseIterable {
    case advertisementUpbeat, affectionate, angry, assistant, calm, chat, cheerful, customerService, _default, depressed, disgruntled, documentaryNarration, embarrassed, empathetic, envious, excited, fearful, friendly, gentle, hopeful, lyrical, narrationProfessional, narrationRelaxed, newscast, newscastCasual, newscastFormal, poetryReading, sad, serious, shouting, sportsCommentary, sportsCommentaryExcited, whispering, terrified, unfriendly, sorry

    init?(rawValue: String) {
        self = SpeechStyle.allCases.first(where: { $0.ssmlName == rawValue}) ?? ._default
    }

    var ssmlName: String {
        switch self {
        case .advertisementUpbeat:
            "advertisement_upbeat"
        case .customerService:
            "customerservice"
        case ._default:
            "default"
        case .documentaryNarration:
            "documentary-narration"
        case .narrationProfessional:
            "narration-professional"
        case .narrationRelaxed:
            "narration-relaxed"
        case .newscastCasual:
            "newscast-casual"
        case .newscastFormal:
            "newscast-formal"
        case .poetryReading:
            "poetry-reading"
        case .sportsCommentary:
            "sports_commentary"
        case .sportsCommentaryExcited:
            "sports_commentary_excited"
        default:
            rawValue
        }
    }
}
