//
//  WordTimeStampData.swift
//  FlowTale
//
//  Created by iakalann on 23/10/2024.
//

import Foundation

public struct WordTimeStampData: Codable, Equatable, Hashable {
    let id: UUID
    let storyId: UUID
    let chapterIndex: Int
    public var word: String
    public let time: Double
    public var duration: Double

    public init(id: UUID,
         storyId: UUID,
         chapterIndex: Int,
         word: String,
         time: Double,
         duration: Double)
    {
        self.id = id
        self.storyId = storyId
        self.chapterIndex = chapterIndex
        self.word = word
        self.time = time
        self.duration = duration
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        storyId = (try? container.decode(UUID.self, forKey: .storyId)) ?? UUID()
        chapterIndex = (try? container.decode(Int.self, forKey: .chapterIndex)) ?? 0
        word = try container.decode(String.self, forKey: .word)
        time = try container.decode(Double.self, forKey: .time)
        duration = try container.decode(Double.self, forKey: .duration)
    }
}
