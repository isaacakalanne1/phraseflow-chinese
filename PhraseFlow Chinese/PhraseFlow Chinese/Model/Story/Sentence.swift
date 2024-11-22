//
//  Sentence.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Codable, Equatable, Hashable {
    let translation: String
    let english: String

    init(translation: String,
         english: String) {
        self.translation = translation
        self.english = english
    }

    var convertedTranslation: [String] {
        translation.components(separatedBy: " ")
    }
}

func sentenceSchema(languageKey: String) -> [String: Any] {
    [
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
                                languageKey: ["type": "string"]
                            ],
                            "required": ["english", languageKey],
                            "additionalProperties": false
                        ]
                    ]
                ],
                "required": ["sentences", "latestStorySummary"],
                "additionalProperties": false
            ]
        ]
    ]

}
