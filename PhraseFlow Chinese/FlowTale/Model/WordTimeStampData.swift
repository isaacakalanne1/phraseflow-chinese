//
//  WordTimeStampData.swift
//  FlowTale
//
//  Created by iakalann on 23/10/2024.
//

import Foundation

struct WordTimeStampData: Codable, Equatable, Hashable {
    let id: UUID
    let storyId: UUID
    let chapterIndex: Int
    var word: String
    let time: Double
    var duration: Double
    var sentenceIndex: Int

    init(id: UUID,
         storyId: UUID,
         chapterIndex: Int,
         word: String,
         time: Double,
         duration: Double,
         sentenceIndex: Int) {
        self.id = id
        self.storyId = storyId
        self.chapterIndex = chapterIndex
        self.word = word
        self.time = time
        self.duration = duration
        self.sentenceIndex = sentenceIndex
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.storyId = (try? container.decode(UUID.self, forKey: .storyId)) ?? UUID()
        self.chapterIndex = (try? container.decode(Int.self, forKey: .chapterIndex)) ?? 0
        self.word = try container.decode(String.self, forKey: .word)
        self.time = try container.decode(Double.self, forKey: .time)
        self.duration = try container.decode(Double.self, forKey: .duration)
        self.sentenceIndex = try container.decode(Int.self, forKey: .sentenceIndex)
    }
}
