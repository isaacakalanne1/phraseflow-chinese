//
//  Definition.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

struct Definition: Codable, Equatable, Hashable, Identifiable {
    var id: UUID
    var creationDate: Date
    var studiedDates: [Date]
    var detail: WordDefinition
    var language: Language
    
    init(id: UUID = UUID(),
         creationDate: Date,
         studiedDates: [Date] = [],
         detail: WordDefinition,
         language: Language) {
        self.id = id
        self.creationDate = creationDate
        self.studiedDates = studiedDates
        self.detail = detail
        self.language = language
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.studiedDates = (try? container.decode([Date].self, forKey: .studiedDates)) ?? []
        self.detail = try container.decode(WordDefinition.self, forKey: .detail)
        self.language = try container.decode(Language.self, forKey: .language)
        // hasBeenSeen is now stored in WordTimeStampData
    }
}

func definitionSchema() -> [String: Any] {
    let wordProperties: [String: Any] = [
        "word": ["type": "string"],
        "pronunciation": ["type": "string"],
        "definition": ["type": "string"],
        "definitionInContextOfSentence": ["type": "string"]
    ]

    return [
        "type": "json_schema",
        "json_schema": [
            "name": "wordDefinitions",
            "strict": true,
            "schema": [
                "type": "object",
                "properties": [
                    "words": [
                        "type": "array",
                        "items": [
                            "type": "object",
                            "properties": wordProperties,
                            "required": [
                                "word",
                                "pronunciation",
                                "definition",
                                "definitionInContextOfSentence"
                            ],
                            "additionalProperties": false
                        ]
                    ]
                ],
                "required": ["words"],
                "additionalProperties": false
            ]
        ]
    ]
}
