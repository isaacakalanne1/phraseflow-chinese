//
//  ChapterResponseDecoder.swift
//  FlowTale
//
//  Created by iakalann on 12/04/2025.
//

import Foundation

public extension JSONDecoder {
    static func createChapterResponseDecoder(
        deviceLanguageKey: String,
        targetLanguageKey: String
    ) -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { keys -> CodingKey in
            let lastKey = keys.last!
            guard lastKey.intValue == nil else { return lastKey }
            
            let deviceLanguageSchemaKey = deviceLanguageKey + "Only"
            let targetLanguageSchemaKey = targetLanguageKey + "Only"
            let deviceLanguageCapitalized = deviceLanguageKey.prefix(1).capitalized + deviceLanguageKey.dropFirst()
            
            switch lastKey.stringValue {
            case "\(deviceLanguageSchemaKey)Translation":
                return AnyKey(stringValue: "original")!
            case targetLanguageSchemaKey:
                return AnyKey(stringValue: "translation")!
            case "briefLatestStorySummaryIn\(deviceLanguageCapitalized)":
                return AnyKey(stringValue: "briefLatestStorySummary")!
            case "chapterNumberAndTitleIn\(deviceLanguageCapitalized)":
                return AnyKey(stringValue: "chapterNumberAndTitle")!
            case "titleOfNovelIn\(deviceLanguageCapitalized)":
                return AnyKey(stringValue: "titleOfNovel")!
            default:
                return AnyKey(stringValue: lastKey.stringValue)!
            }
        }
        return decoder
    }
}
