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

    var currentSpokenWord: WordTimeStampData? {
        storyState.currentChapter?.timestampData.last(where: { audioState.currentPlaybackTime >= $0.time })
    }
}
