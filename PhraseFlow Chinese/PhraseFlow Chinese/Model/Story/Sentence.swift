//
//  Sentence.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Codable, Equatable, Hashable {
    let mandarin: String
    let englishTranslation: String
    let speechStyle: SpeechStyle
    let speechRole: SpeechRole

    init(mandarin: String,
         englishTranslation: String,
         speechStyle: SpeechStyle,
         speechRole: SpeechRole) {
        self.mandarin = mandarin
        self.englishTranslation = englishTranslation
        self.speechStyle = speechStyle
        self.speechRole = speechRole
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.englishTranslation = try container.decode(String.self, forKey: .englishTranslation)
        self.speechStyle = try container.decode(SpeechStyle.self, forKey: .speechStyle)
        self.speechRole = try container.decode(SpeechRole.self, forKey: .speechRole)
    }
}

let sentenceSchema: [String: Any] = [
    "type": "json_schema",
    "json_schema": [
        "name": "sentences",
        "strict": true,
        "schema": [
            "type": "object",
            "properties": [
                "latestStorySummary": ["type": "string"],
                "sentences": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "mandarin": ["type": "string"],
                            "englishTranslation": ["type": "string"],
                            "speechStyle": ["type": "string"],
                            "speechRole": ["type": "string"]
                        ],
                        "required": ["mandarin", "englishTranslation", "speechStyle", "speechRole"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["sentences", "latestStorySummary"],
            "additionalProperties": false
        ]
    ]
]
