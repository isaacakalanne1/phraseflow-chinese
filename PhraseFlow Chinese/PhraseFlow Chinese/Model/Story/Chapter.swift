//
//  Chapter.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Chapter: Codable, Equatable, Hashable {
    var sentences: [Sentence]
    var index: Int
}
