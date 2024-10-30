//
//  Chapter.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation
import AVKit

struct Chapter: Codable, Equatable, Hashable {
    var passage: String {
        sentences.reduce("") { $0 + $1.mandarin }
    }
    var storyTitle: String
    var sentences: [Sentence]
    var audioData: Data?
    var timestampData: [WordTimeStampData] = []
}
