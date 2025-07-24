//
//  SettingsState.swift
//  FlowTale
//
//  Created by iakalann on 06/11/2024.
//

import SwiftUI

public struct SettingsState: Codable, Equatable, Sendable {
    var isShowingDefinition: Bool
    var isShowingEnglish: Bool
    public var isPlayingMusic: Bool
    var voice: Voice
    var speechSpeed: SpeechSpeed
    var difficulty: Difficulty
    var language: Language
    var customPrompt: String
    var storySetting: StorySetting
    var confirmedCustomPrompt: String
    var customPrompts: [String]
    var appColorScheme: FlowTaleColorScheme?
    var shouldPlaySound: Bool
    var isShowingCustomPromptAlert: Bool

    init(isShowingDefinition: Bool = true,
         isShowingEnglish: Bool = true,
         isPlayingMusic: Bool = true,
         voice: Voice = .xiaoxiao,
         speechSpeed: SpeechSpeed = .normal,
         difficulty: Difficulty = .beginner,
         language: Language = .mandarinChinese,
         customPrompt: String = "",
         storySetting: StorySetting = .random,
         customPrompts: [String] = [],
         colorScheme: FlowTaleColorScheme = .dark,
         shouldPlaySound: Bool = true,
         isShowingCustomPromptAlert: Bool = true,
         confirmedCustomPrompt: String = "") {
        self.isShowingDefinition = isShowingDefinition
        self.isShowingEnglish = isShowingEnglish
        self.isPlayingMusic = isPlayingMusic
        self.voice = voice
        self.speechSpeed = speechSpeed
        self.difficulty = difficulty
        self.language = language
        self.customPrompt = customPrompt
        self.customPrompts = customPrompts
        self.storySetting = storySetting
        self.confirmedCustomPrompt = confirmedCustomPrompt
        self.appColorScheme = colorScheme
        self.shouldPlaySound = shouldPlaySound
        self.isShowingCustomPromptAlert = isShowingCustomPromptAlert
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isShowingDefinition = try container.decode(Bool.self, forKey: .isShowingDefinition)
        self.isShowingEnglish = try container.decode(Bool.self, forKey: .isShowingEnglish)
        self.isPlayingMusic = try container.decode(Bool.self, forKey: .isPlayingMusic)
        self.voice = try container.decode(Voice.self, forKey: .voice)
        self.speechSpeed = try container.decode(SpeechSpeed.self, forKey: .speechSpeed)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.language = try container.decode(Language.self, forKey: .language)
        self.customPrompt = try container.decode(String.self, forKey: .customPrompt)
        self.storySetting = try container.decode(StorySetting.self, forKey: .storySetting)
        self.confirmedCustomPrompt = try container.decode(String.self, forKey: .confirmedCustomPrompt)
        self.customPrompts = try container.decode([String].self, forKey: .customPrompts)
        
        self.appColorScheme = (try? container.decode(FlowTaleColorScheme?.self, forKey: .appColorScheme)) ?? .dark
        self.shouldPlaySound = (try? container.decode(Bool.self, forKey: .shouldPlaySound)) ?? true
        self.isShowingCustomPromptAlert = (try? container.decode(Bool.self, forKey: .isShowingCustomPromptAlert)) ?? false
    }
}
