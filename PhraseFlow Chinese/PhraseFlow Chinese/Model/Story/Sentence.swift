//
//  Sentence.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Codable, Equatable, Hashable {
    let translation: String
    let original: String

    init(translation: String,
         english: String) {
        self.translation = translation
        self.original = english
    }

    var convertedTranslation: [String] {
        translation.components(separatedBy: " ")
    }
}

func sentenceSchema(originalKey: String,
                    languageKey: String,
                    originalLanguageName: String,
                    languageName: String,
                    shouldCreateTitle: Bool) -> [String: Any] {
    var properties: [String: Any] = [
        "briefLatestStorySummaryIn\(originalLanguageName)": ["type": "string"],
        "chapterNumberAndTitleIn\(originalLanguageName)": ["type": "string"],
        "sentences": [
            "type": "array",
            "items": [
                "type": "object",
                "properties": [
                    originalKey: ["type": "string"],
                    languageKey: ["type": "string"]
                ],
                "required": [originalKey, languageKey],
                "additionalProperties": false
            ]
        ]
    ]

    if shouldCreateTitle {
        properties["titleOfNovelIn\(originalLanguageName)"] = ["type": "string"]
    }

    var required: [String] = [
        "sentences",
        "briefLatestStorySummaryIn\(originalLanguageName)",
        "chapterNumberAndTitleIn\(originalLanguageName)"
    ]
    if shouldCreateTitle {
        required.append("titleOfNovelIn\(originalLanguageName)")
    }

    return [
        "type": "json_schema",
        "json_schema": [
            "name": "sentences",
            "strict": true,
            "schema": [
                "type": "object",
                "properties": properties,
                "required": required,
                "additionalProperties": false
            ]
        ]
    ]

}
