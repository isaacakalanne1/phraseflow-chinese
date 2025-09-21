//
//  SettingsState+Arrange.swift
//  Settings
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Settings
import DataStorage

public extension SettingsState {
    static var arrange: SettingsState {
        .arrange()
    }
    
    static func arrange(
        isShowingDefinition: Bool = true,
        isShowingEnglish: Bool = true,
        isPlayingMusic: Bool = true,
        voice: Voice = .elvira,
        speechSpeed: SpeechSpeed = .normal,
        difficulty: Difficulty = .beginner,
        language: Language = .spanish,
        sourceLanguage: Language = .autoDetect,
        targetLanguage: Language = .spanish,
        customPrompt: String = "",
        storySetting: StorySetting = .random,
        customPrompts: [String] = [],
        shouldPlaySound: Bool = true,
        isShowingCustomPromptAlert: Bool = true,
        isShowingModerationFailedAlert: Bool = false,
        viewState: SettingsViewState = .arrange,
        usedCharacters: Int = 0,
        subscriptionLevel: SubscriptionLevel = .free
    ) -> SettingsState {
        .init(
            isShowingDefinition: isShowingDefinition,
            isShowingEnglish: isShowingEnglish,
            isPlayingMusic: isPlayingMusic,
            voice: voice,
            speechSpeed: speechSpeed,
            difficulty: difficulty,
            language: language,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            customPrompt: customPrompt,
            storySetting: storySetting,
            customPrompts: customPrompts,
            shouldPlaySound: shouldPlaySound,
            isShowingCustomPromptAlert: isShowingCustomPromptAlert,
            isShowingModerationFailedAlert: isShowingModerationFailedAlert,
            viewState: viewState,
            usedCharacters: usedCharacters,
            subscriptionLevel: subscriptionLevel
        )
    }
}
