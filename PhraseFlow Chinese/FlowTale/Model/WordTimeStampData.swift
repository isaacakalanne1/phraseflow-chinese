//
//  WordTimeStampData.swift
//  FlowTale
//
//  Created by iakalann on 23/10/2024.
//

import Foundation

// Forward declaration for Definition struct (defined in Definition.swift)

struct WordTimeStampData: Codable, Equatable, Hashable {
    let id: UUID
    let storyId: UUID
    let sentenceId: UUID
    var word: String
    let time: Double
    var duration: Double
    var definition: Definition?
    var hasBeenSeen: Bool = false

    init(id: UUID,
         storyId: UUID,
         sentenceId: UUID,
         word: String,
         time: Double,
         duration: Double,
         definition: Definition? = nil,
         hasBeenSeen: Bool = false) {
        self.id = id
        self.storyId = storyId
        self.sentenceId = sentenceId
        self.word = word
        self.time = time
        self.duration = duration
        self.definition = definition
        self.hasBeenSeen = hasBeenSeen
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.storyId = (try? container.decode(UUID.self, forKey: .storyId)) ?? UUID()
        self.sentenceId = (try? container.decode(UUID.self, forKey: .sentenceId)) ?? UUID()
        self.word = try container.decode(String.self, forKey: .word)
        self.time = try container.decode(Double.self, forKey: .time)
        self.duration = try container.decode(Double.self, forKey: .duration)
        self.definition = try? container.decodeIfPresent(Definition.self, forKey: .definition)
        self.hasBeenSeen = (try? container.decode(Bool.self, forKey: .hasBeenSeen)) ?? false
    }
}
