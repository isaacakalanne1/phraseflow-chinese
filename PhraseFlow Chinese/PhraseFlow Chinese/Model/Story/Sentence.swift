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

func sentenceSchema(originalLanguage: Language,
                    translationLanguage: Language,
                    shouldCreateTitle: Bool) -> [String: Any] {
    var properties: [String: Any] = [
        "briefLatestStorySummaryIn\(originalLanguage.key)": ["type": "string"],
        "chapterNumberAndTitleIn\(originalLanguage.key)": ["type": "string"],
        "sentences": [
            "type": "array",
            "items": [
                "type": "object",
                "properties": [
                    originalLanguage.schemaKey: ["type": "string"],
                    translationLanguage.schemaKey: ["type": "string"]
                ],
                "required": [originalLanguage.schemaKey, translationLanguage.schemaKey],
                "additionalProperties": false
            ]
        ]
    ]

    if shouldCreateTitle {
        properties["titleOfNovelIn\(originalLanguage.key)"] = ["type": "string"]
    }

    var required: [String] = [
        "sentences",
        "briefLatestStorySummaryIn\(originalLanguage.key)",
        "chapterNumberAndTitleIn\(originalLanguage.key)"
    ]
    if shouldCreateTitle {
        required.append("titleOfNovelIn\(originalLanguage.key)")
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
