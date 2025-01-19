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

    var passageWithoutNewLines: String {
        sentences.reduce("") { $0 + $1.original }
    }

    var passage: String {
        let newLine = """


"""
        return sentences.reduce("") { $0 + newLine + $1.original }
    }
}
