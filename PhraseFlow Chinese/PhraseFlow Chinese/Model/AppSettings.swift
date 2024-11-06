//
//  AppSettings.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 06/11/2024.
//

import Foundation

struct AppSettings: Codable {
    var isShowingPinyin: Bool
    var isShowingDefinition: Bool
    var isShowingEnglish: Bool
    var voice: Voice
    var speechSpeed: SpeechSpeed
}
