//
//  Chapter.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import Foundation
import AVKit

struct Chapter: Codable, Equatable, Hashable {


    var passageWithoutNewLines: String {
        return sentences.reduce("") { $0 + $1.original }
    }
    var passage: String {
        let newLine = """


"""
        return sentences.reduce("") { $0 + newLine + $1.original }
    }
    var title: String
    var sentences: [Sentence]
    var audioVoice: Voice?
    var audioSpeed: SpeechSpeed?
    var audioData: Data?
    var timestampData: [WordTimeStampData] = []
}
