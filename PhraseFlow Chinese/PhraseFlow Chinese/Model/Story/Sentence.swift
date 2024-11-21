//
//  Sentence.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Codable, Equatable, Hashable {
    let mandarinTranslation: String
    let english: String

    init(mandarinTranslation: String,
         english: String) {
        self.mandarinTranslation = mandarinTranslation
        self.english = english
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarinTranslation = try container.decode(String.self, forKey: .mandarinTranslation)
        self.english = try container.decode(String.self, forKey: .english)
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
                            "english": ["type": "string"],
                            "mandarinTranslation": ["type": "string"]
                        ],
                        "required": ["english", "mandarinTranslation"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["sentences", "latestStorySummary"],
            "additionalProperties": false
        ]
    ]
]
