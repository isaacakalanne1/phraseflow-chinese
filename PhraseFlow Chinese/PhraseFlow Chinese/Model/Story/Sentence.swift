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
    let speechRole: SpeechRole

    init(mandarin: String,
         englishTranslation: String,
         speechRole: SpeechRole) {
        self.mandarin = mandarin
        self.englishTranslation = englishTranslation
        self.speechRole = speechRole
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.englishTranslation = try container.decode(String.self, forKey: .englishTranslation)
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
                            "speechRole": ["type": "string"]
                        ],
                        "required": ["mandarin", "englishTranslation", "speechRole"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["sentences", "latestStorySummary"],
            "additionalProperties": false
        ]
    ]
]
