//
//  SettingsState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 06/11/2024.
//

import Foundation

struct SettingsState: Codable {
    var isShowingPinyin: Bool
    var isShowingDefinition: Bool
    var isShowingEnglish: Bool
    var voice: Voice
    var speechSpeed: SpeechSpeed
    var difficulty: Difficulty

    init(isShowingPinyin: Bool = true,
         isShowingDefinition: Bool = true,
         isShowingEnglish: Bool = true,
         voice: Voice = .xiaoxiao,
         speechSpeed: SpeechSpeed = .normal,
         difficulty: Difficulty = .beginner) {
        self.isShowingPinyin = isShowingPinyin
        self.isShowingDefinition = isShowingDefinition
        self.isShowingEnglish = isShowingEnglish
        self.voice = voice
        self.speechSpeed = speechSpeed
        self.difficulty = difficulty
    }
}
