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

    init(mandarin: String,
         englishTranslation: String) {
        self.mandarin = mandarin
        self.englishTranslation = englishTranslation
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.englishTranslation = try container.decode(String.self, forKey: .englishTranslation)
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
                            "englishTranslation": ["type": "string"]
                        ],
                        "required": ["mandarin", "englishTranslation"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["sentences", "latestStorySummary"],
            "additionalProperties": false
        ]
    ]
]
