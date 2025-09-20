//
//  Definition.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import Foundation
import Settings
import TextGeneration

public struct Definition: Codable, Equatable, Hashable, Sendable {
    var id: UUID // Unique identifier for this definition
    public var creationDate: Date
    var studiedDates: [Date]
    public var timestampData: WordTimeStampData
    public var sentence: Sentence
    var detail: WordDefinition
    var language: Language
    public var hasBeenSeen: Bool
    public var sentenceId: UUID // ID for the extracted sentence audio
    public var storyId: UUID
    public var audioData: Data?

    public init(
        id: UUID = UUID(),
        creationDate: Date = Date(),
        studiedDates: [Date] = [],
        timestampData: WordTimeStampData,
        sentence: Sentence,
        detail: WordDefinition,
        language: Language,
        hasBeenSeen: Bool = false,
        sentenceId: UUID,
        storyId: UUID,
        audioData: Data? = nil
    ) {
        self.id = id
        self.creationDate = creationDate
        self.studiedDates = studiedDates
        self.timestampData = timestampData
        self.sentence = sentence
        self.detail = detail
        self.language = language
        self.hasBeenSeen = hasBeenSeen
        self.sentenceId = sentenceId
        self.storyId = storyId
        self.audioData = audioData
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        studiedDates = (try? container.decode([Date].self, forKey: .studiedDates)) ?? []
        timestampData = try container.decode(WordTimeStampData.self, forKey: .timestampData)
        sentence = try container.decode(Sentence.self, forKey: .sentence)
        detail = try container.decode(WordDefinition.self, forKey: .detail)
        language = try container.decode(Language.self, forKey: .language)
        hasBeenSeen = (try? container.decode(Bool.self, forKey: .hasBeenSeen)) ?? false
        sentenceId = (try? container.decode(UUID.self, forKey: .sentenceId)) ?? UUID()
        storyId = (try? container.decode(UUID.self, forKey: .storyId)) ?? UUID()
        audioData = try? container.decode(Data.self, forKey: .audioData)
    }
    
    public var word: String {
        detail.word
    }
    
    public var pronunciation: String {
        detail.pronunciation
    }
    
    public var definition: String {
        detail.definition
    }
    
    public var definitionInContextOfSentence: String {
        detail.definitionInContextOfSentence
    }

}

public func definitionSchema() -> [String: Any] {
    let wordProperties: [String: Any] = [
        "word": ["type": "string"],
        "pronunciation": ["type": "string"],
        "definition": ["type": "string"],
        "definitionInContextOfSentence": ["type": "string"],
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
                                "definitionInContextOfSentence",
                            ],
                            "additionalProperties": false,
                        ],
                    ],
                ],
                "required": ["words"],
                "additionalProperties": false,
            ],
        ],
    ]
}
