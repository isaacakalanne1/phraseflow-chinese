//
//  ChapterResponseDecoder.swift
//  FlowTale
//
//  Created by iakalann on 12/04/2025.
//

import Foundation

extension JSONDecoder {
    static func createChapterResponseDecoder(
        deviceLanguage: Language,
        targetLanguage: Language
    ) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { keys -> CodingKey in
            let lastKey = keys.last!
            guard lastKey.intValue == nil else { return lastKey }
            switch lastKey.stringValue {
            case "\(deviceLanguage.schemaKey)Translation":
                return AnyKey(stringValue: "original")!
            case targetLanguage.schemaKey:
                return AnyKey(stringValue: "translation")!
            case "briefLatestStorySummaryIn\(deviceLanguage.key)":
                return AnyKey(stringValue: "briefLatestStorySummary")!
            case "chapterNumberAndTitleIn\(deviceLanguage.key)":
                return AnyKey(stringValue: "chapterNumberAndTitle")!
            case "titleOfNovelIn\(deviceLanguage.key)":
                return AnyKey(stringValue: "titleOfNovel")!
            default:
                return AnyKey(stringValue: lastKey.stringValue)!
            }
        }
        return decoder
    }
}
