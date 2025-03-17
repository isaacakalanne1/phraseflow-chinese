//
//  Sentence.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Codable, Equatable, Hashable {
    var id: UUID
    var chapterId: UUID
    var chapterIndex: Int
    var translation: String
    let original: String
    var wordTimestamps: [WordTimeStampData]

    init(chapterId: UUID,
         chapterIndex: Int,
         translation: String,
         original: String,
         wordTimestamps: [WordTimeStampData] = []) {
        self.id = UUID()
        self.chapterId = chapterId
        self.chapterIndex = chapterIndex
        self.translation = translation
        self.original = original
        self.wordTimestamps = wordTimestamps
        self.chapterId = UUID()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .translation)) ?? UUID()
        self.chapterId = (try? container.decode(UUID.self, forKey: .translation)) ?? UUID()
        self.chapterIndex = (try? container.decode(Int.self, forKey: .chapterIndex)) ?? 0
        self.translation = try container.decode(String.self, forKey: .translation)
        self.original = try container.decode(String.self, forKey: .original)
        self.wordTimestamps = (try? container.decode([WordTimeStampData].self, forKey: .wordTimestamps)) ?? []
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
