//
//  FastChineseReducer.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit

let fastChineseReducer: Reducer<FastChineseState, FastChineseAction> = { state, action in
    var newState = state

    switch action {
    case .onGeneratedNewChapter(let story):
        newState.currentStory = story
        newState.sentenceIndex = 0
        newState.isShowingCreateStoryScreen = false
    case .onGeneratedStory(let story):
        newState.currentStory = story
    case .onLoadedStories(let stories):
        newState.savedStories = stories
        if newState.currentStory == nil,
           !stories.isEmpty {
            newState.currentStory = stories.first
        }
    case .goToNextSentence:
        if let chapter = newState.currentChapter,
           newState.sentenceIndex + 1 < chapter.sentences.count {
            newState.sentenceIndex = newState.sentenceIndex + 1
            newState.currentDefinition = nil
        }
    case .updateSpeechSpeed(let speed):
        newState.speechSpeed = speed
    case .defineCharacter(let character):
        newState.characterToDefine = character
    case .onDefinedCharacter(let definition):
        if let sentence = newState.currentSentence {
            newState.currentDefinition = .init(character: newState.characterToDefine,
                                               sentence: sentence,
                                               definition: definition)
        }
    case .onSynthesizedAudio(let data):
        newState.timestampData = data.wordTimestamps
        newState.audioPlayer = try? AVAudioPlayer(data: data.audioData)
        newState.audioPlayer?.prepareToPlay()
    case .updateShowPinyin(let isShowing):
        newState.isShowingPinyin = isShowing
    case .updateShowMandarin(let isShowing):
        newState.isShowingMandarin = isShowing
    case .updateShowEnglish(let isShowing):
        newState.isShowingEnglish = isShowing
    case .updateShowingCreateStoryScreen(let isShowing):
        newState.isShowingCreateStoryScreen = isShowing
    case .updateShowingSettings(let isShowing):
        newState.isShowingSettingsScreen = isShowing
    case .updateShowingStoryListView(let isShowing):
        newState.isShowingStoryListView = isShowing
    case .updateSelectCategory(let category, let isSelected):
        if isSelected {
            if !newState.selectedCategories.contains(category) {
                newState.selectedCategories.append(category)
            }
        } else {
            newState.selectedCategories.removeAll(where: { $0 == category })
        }
    case .selectStory(let story):
        newState.currentStory = story
        newState.sentenceIndex = 0
    case .saveStory,
            .failedToSaveStory,
            .failedToLoadStories,
            .playAudio,
            .failedToPlayAudio,
            .failedToDefineCharacter,
            .generateNewStory,
            .failedToGenerateNewStory,
            .generateNewChapter,
            .failedToGenerateNewChapter,
            .loadStories,
            .synthesizeAudio,
            .onPlayedAudio:
        break
    }

    return newState
}
