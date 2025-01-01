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
    var definition: String
    var language: Language

    init(creationDate: Date,
         studiedDates: [Date] = [],
         timestampData: WordTimeStampData,
         sentence: Sentence,
         definition: String,
         language: Language) {
        self.creationDate = creationDate
        self.studiedDates = studiedDates
        self.timestampData = timestampData
        self.sentence = sentence
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
        self.language = try container.decode(Language.self, forKey: .language)
    }
}
