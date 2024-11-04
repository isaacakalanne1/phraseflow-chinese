//
//  ChapterType.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 29/10/2024.
//

import Foundation

enum ChapterType {
    case first(setting: StorySetting)
    case next(previousChapter: Chapter)
}
