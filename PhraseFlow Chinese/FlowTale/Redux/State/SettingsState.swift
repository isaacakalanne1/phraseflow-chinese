//
//  SettingsState.swift
//  FlowTale
//
//  Created by iakalann on 06/11/2024.
//

import Foundation

enum StorySetting: Codable, Equatable {
    case random, customPrompt(String)
}

struct SettingsState: Codable {
    var isShowingDefinition: Bool
    var isShowingEnglish: Bool
    var isPlayingMusic: Bool
    var voice: Voice
    var speechSpeed: SpeechSpeed
    var difficulty: Difficulty
    var storyPrompt: String
    var language: Language
    var customPrompt: String
    var storySetting: StorySetting
    var confirmedCustomPrompt: String
    var customPrompts: [String]

    init(isShowingDefinition: Bool = true,
         isShowingEnglish: Bool = true,
         isPlayingMusic: Bool = true,
         voice: Voice = .xiaoxiao,
         speechSpeed: SpeechSpeed = .normal,
         difficulty: Difficulty = .beginner,
         storyPrompt: String = "medieval town",
         language: Language = .mandarinChinese,
         customPrompt: String = "",
         storySetting: StorySetting = .random,
         customPrompts: [String] = [],
         confirmedCustomPrompt: String = "") {
        self.isShowingDefinition = isShowingDefinition
        self.isShowingEnglish = isShowingEnglish
        self.isPlayingMusic = isPlayingMusic
        self.voice = voice
        self.speechSpeed = speechSpeed
        self.difficulty = difficulty
        self.storyPrompt = storyPrompt
        self.language = language
        self.customPrompt = customPrompt
        self.customPrompts = customPrompts
        self.storySetting = storySetting
        self.confirmedCustomPrompt = confirmedCustomPrompt
    }
}
