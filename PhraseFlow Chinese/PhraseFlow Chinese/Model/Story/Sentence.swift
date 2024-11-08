//
//  Sentence.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct SentenceResponse: Codable {
    let sentences: [Sentence]
}

struct Sentence: Codable, Equatable, Hashable {
    let mandarin: String
    let pinyin: [String]
    let english: String
    let speechStyle: SpeechStyle
    let speechRole: SpeechRole

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.pinyin = try container.decode([String].self, forKey: .pinyin)
        self.english = try container.decode(String.self, forKey: .english)
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
                            "pinyin": ["type": "array", "items": ["type": "string"]],
                            "english": ["type": "string"],
                            "speechStyle": ["type": "string"],
                            "speechRole": ["type": "string"]
                        ],
                        "required": ["mandarin", "pinyin", "english", "speechStyle", "speechRole"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["sentences", "latestStorySummary"],
            "additionalProperties": false
        ]
    ]
]
