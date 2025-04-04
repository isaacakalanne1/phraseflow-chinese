//
//  Chapter.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Chapter: Codable, Equatable, Hashable {
    var title: String
    var sentences: [Sentence]
    var audioVoice: Voice?
    var audioSpeed: SpeechSpeed?
    var audio: ChapterAudio
    var passage: String

    init(title: String,
         sentences: [Sentence],
         audioVoice: Voice? = nil,
         audioSpeed: SpeechSpeed? = nil,
         audio: ChapterAudio,
         passage: String) {
        self.title = title
        self.sentences = sentences
        self.audioVoice = audioVoice
        self.audioSpeed = audioSpeed
        self.audio = audio
        self.passage = passage
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.sentences = try container.decode([Sentence].self, forKey: .sentences)
        self.audioVoice = try container.decodeIfPresent(Voice.self, forKey: .audioVoice)
        self.audioSpeed = try container.decodeIfPresent(SpeechSpeed.self, forKey: .audioSpeed)
        self.audio = (try? container.decode(ChapterAudio.self, forKey: .audio)) ?? ChapterAudio(timestamps: [], data: Data())
        let newLine = """


"""
        self.passage = (try? container.decode(String.self, forKey: .audio)) ?? sentences.reduce("") { $0 + newLine + $1.original }
    }
}
