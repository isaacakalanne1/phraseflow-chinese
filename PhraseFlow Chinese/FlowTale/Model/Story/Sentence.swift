//
//  Sentence.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Codable, Equatable, Hashable {
    let id: UUID
    let translation: String
    let original: String

    init(id: UUID,
         translation: String,
         english: String) {
        self.id = id
        self.translation = translation
        self.original = english
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.translation = try container.decode(String.self, forKey: .translation)
        self.original = try container.decode(String.self, forKey: .original)
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
                    translationLanguage.schemaKey: ["type": "string"],
                    "\(originalLanguage.schemaKey)Translation": ["type": "string"]
                ],
                "required": [
                    translationLanguage.schemaKey,
                    "\(originalLanguage.schemaKey)Translation",
                ],
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
