//
//  ChapterGenerationInfo.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct StoryGenerationInfo: Codable {
    var id = UUID()
    let storyOverview: String
    let difficulty: Int
}
