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
    var hasBeenSeen: Bool
    var sentenceId: UUID?  // ID for the extracted sentence audio
    var audioData: Data?

    init(creationDate: Date,
         studiedDates: [Date] = [],
         timestampData: WordTimeStampData,
         sentence: Sentence,
         detail: WordDefinition,
         definition: String,
         language: Language,
         hasBeenSeen: Bool = false,
         sentenceId: UUID? = nil,
         audioData: Data? = nil) {
        self.creationDate = creationDate
        self.studiedDates = studiedDates
        self.timestampData = timestampData
        self.sentence = sentence
        self.detail = detail
        self.definition = definition
        self.language = language
        self.hasBeenSeen = hasBeenSeen
        self.sentenceId = sentenceId
        self.audioData = audioData
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
        self.hasBeenSeen = (try? container.decode(Bool.self, forKey: .hasBeenSeen)) ?? false
        self.sentenceId = try? container.decode(UUID?.self, forKey: .sentenceId)
        self.audioData = try? container.decode(Data.self, forKey: .audioData)
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
