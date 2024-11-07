//
//  ChapterResponse.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 29/10/2024.
//

import Foundation

struct ChapterResponse: Codable {
//    let latestStorySummary: String
//    let storyTitle: String
    let sentences: [Sentence]
}
