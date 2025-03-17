//
//  Chapter.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Chapter: Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var sentences: [Sentence]
    var audioVoice: Voice?
    var audioData: Data?
    var passage: String

    init(id: UUID = UUID(),
         title: String,
         sentences: [Sentence],
         audioVoice: Voice? = nil,
         audioData: Data? = nil,
         passage: String) {
        self.id = id
        self.title = title
        self.sentences = sentences
        self.audioVoice = audioVoice
        self.audioData = audioData
        self.passage = passage
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .title)) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.sentences = try container.decode([Sentence].self, forKey: .sentences)
        self.audioVoice = try container.decodeIfPresent(Voice.self, forKey: .audioVoice)
        self.audioData = try? container.decode(Data?.self, forKey: .audioData)
        let newLine = """


"""
        self.passage = (try? container.decode(String.self, forKey: .passage)) ?? sentences.reduce("") { $0 + newLine + $1.original }
    }
}
