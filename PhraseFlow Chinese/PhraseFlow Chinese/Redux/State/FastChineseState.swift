//
//  FastChineseState.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

struct FastChineseState {
    var settingsState = SettingsState()
    var storyState = StoryState()
    var audioState = AudioState()
    var definitionState = DefinitionState()
    var viewState = ViewState()
    var subscriptionState = SubscriptionState()

    var currentSpokenWord: WordTimeStampData? {
        storyState.currentChapter?.timestampData.last(where: { audioState.currentPlaybackTime >= $0.time })
    }

    func createNewStory() -> Story {
        return Story(difficulty: settingsState.difficulty,
                     language: settingsState.language,
                     title: "",
                     storyPrompt: StoryPrompts.all.randomElement() ?? "a medieval town")
    }
}
