//
//  Definition.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

struct Definition: Codable, Equatable, Hashable {
    var creationDate: Date
    var studiedDates: [Date]
    var timestampData: WordTimeStampData
    var sentence: Sentence
    var detail: WordDefinition
    var definition: String
    var language: Language

    init(creationDate: Date,
         studiedDates: [Date] = [],
         timestampData: WordTimeStampData,
         sentence: Sentence,
         detail: WordDefinition,
         definition: String,
         language: Language) {
        self.creationDate = creationDate
        self.studiedDates = studiedDates
        self.timestampData = timestampData
        self.sentence = sentence
        self.detail = detail
        self.definition = definition
        self.language = language
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.studiedDates = (try? container.decode([Date].self, forKey: .studiedDates)) ?? []
        self.timestampData = try container.decode(WordTimeStampData.self, forKey: .timestampData)
        self.sentence = try container.decode(Sentence.self, forKey: .sentence)
        self.definition = try container.decode(String.self, forKey: .definition)
        self.detail = try container.decode(WordDefinition.self, forKey: .detail)
        self.language = try container.decode(Language.self, forKey: .language)
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
