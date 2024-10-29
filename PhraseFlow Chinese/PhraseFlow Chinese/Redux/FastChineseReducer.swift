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
    case .onGeneratedChapter(let chapter):
        var newStory = newState.currentStory
        if newStory?.chapters.isEmpty == true {
            newStory?.chapters = [chapter]
        } else {
            newStory?.chapters.append(chapter)
        }
        let chapters = newStory?.chapters
        newStory?.currentChapterIndex = (chapters?.count ?? 1) - 1
        newState.currentStory = newStory

        newState.audioPlayer = nil
        newState.viewState = .normal
        newState.sentenceIndex = 0
        newState.isShowingCreateStoryScreen = false
    case .onGeneratedStory(let story):
        newState.currentStory = story
        newState.viewState = .normal
    case .onLoadedStories(let stories):
        newState.savedStories = stories
        let currentStory = stories.first
        if newState.currentStory == nil,
           !stories.isEmpty {
            newState.currentStory = currentStory
            if let data = newState.currentChapterAudioData {
                newState.audioPlayer = try? AVAudioPlayer(data: data)
                newState.audioPlayer?.prepareToPlay()
            }
        }

    case .updateSpeechSpeed(let speed):
        newState.speechSpeed = speed
        newState.audioPlayer?.rate = speed.rate
    case .defineCharacter(let character):
        newState.characterToDefine = character
    case .onDefinedCharacter(let definition):
        if let sentence = newState.currentSentence {
            newState.currentDefinition = .init(character: newState.characterToDefine,
                                               sentence: sentence,
                                               definition: definition)
        }
    case .onSynthesizedAudio(let data):
        var newStory = newState.currentStory
        let chapterIndex = newStory?.currentChapterIndex ?? 0
        newStory?.chapters[chapterIndex].audioData = data.audioData
        newStory?.chapters[chapterIndex].timestampData = data.wordTimestamps
        newState.currentStory = newStory

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
        newState.sentenceIndex = 0
        newState.currentStory = story
        newState.isShowingStoryListView = false
        if let data = newState.currentChapterAudioData {
            newState.audioPlayer = try? AVAudioPlayer(data: data)
            newState.audioPlayer?.prepareToPlay()
        }
    case .selectChapter(let story, let chapterIndex):
        newState.currentStory = story
        newState.sentenceIndex = 0
        newState.isShowingStoryListView = false
        if let chaptersCount = newState.currentStory?.chapters.count,
           chapterIndex > -1,
           chapterIndex < chaptersCount {
            newState.currentStory?.currentChapterIndex = chapterIndex
        }
        if let data = newState.currentChapterAudioData {
            newState.audioPlayer = try? AVAudioPlayer(data: data)
            newState.audioPlayer?.prepareToPlay()
        }
    case .updateSelectedWordIndices(let startIndex, let endIndex):
        newState.selectedWordStartIndex = startIndex
        newState.selectedWordEndIndex = endIndex
    case .clearSelectedWord:
        newState.selectedWordStartIndex = -1
        newState.selectedWordEndIndex = -1
    case .generateNewStory,
            .generateNewPassage:
        newState.viewState = .loading
        newState.isShowingStoryListView = false
        newState.isShowingCreateStoryScreen = false
    case .failedToGenerateNewStory:
        newState.viewState = .failedToGenerateStory
    case .failedToGenerateChapter,
            .failedToGenerateNewPassage:
        newState.viewState = .failedToGenerateChapter
    case .updateSentenceIndex(let index):
        newState.sentenceIndex = index
    case .playAudio:
        newState.isPlayingAudio = true
    case .pauseAudio:
        newState.isPlayingAudio = false
    case .incrementPlayTime(let increment):
        newState.currentPlaybackTime += increment
    case .selectWord(let timestampData):
        newState.currentPlaybackTime = timestampData.time
    case .goToNextChapter:
        var newStory = newState.currentStory
        newStory?.currentChapterIndex += 1
        newState.currentStory = newStory
        if let data = newState.currentChapterAudioData { // TODO: Move this repeated logic in Reducer to a new action, called via middleware for each of these cases
            newState.audioPlayer = try? AVAudioPlayer(data: data)
            newState.audioPlayer?.prepareToPlay()
        }
    case .saveStory,
            .failedToSaveStory,
            .failedToLoadStories,
            .failedToPlayAudio,
            .failedToDefineCharacter,
            .loadStories,
            .synthesizeAudio,
            .onPlayedAudio,
            .onGeneratedNewPassage,
            .generateChapter:
        break
    }

    return newState
}
