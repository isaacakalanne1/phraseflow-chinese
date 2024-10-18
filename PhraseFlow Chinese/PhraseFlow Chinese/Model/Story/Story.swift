//
//  Story.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Story: Codable, Equatable, Hashable {
    let info: StoryGenerationInfo
    let title: String
    let description: String
    var chapters: [Chapter]
}
