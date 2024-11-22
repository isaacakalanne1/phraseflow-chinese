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
    case .onLoadedAppSettings(let settings):
        newState.settingsState = settings
    case .onGeneratedChapter(let story):
        newState.storyState.currentStory = story
        newState.audioState.audioPlayer = AVPlayer()
        newState.viewState.readerDisplayType = .normal
        newState.storyState.sentenceIndex = 0
        newState.viewState.isShowingCreateStoryScreen = false
    case .onGeneratedStory(let story):
        newState.storyState.currentStory = story
        newState.viewState.readerDisplayType = .normal
    case .onLoadedStories(let stories):
        newState.storyState.savedStories = stories
        let currentStory = stories.first
        if newState.storyState.currentStory == nil,
           !stories.isEmpty {
            newState.storyState.currentStory = currentStory
            if let data = newState.storyState.currentChapterAudioData,
               let player = data.createAVPlayer() {
                newState.audioState.audioPlayer = player
            }
        }

    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
    case .defineCharacter(let wordTimeStampData, let shouldForce):
        newState.definitionState.tappedWord = wordTimeStampData
        newState.viewState.readerDisplayType = .defining
    case .onDefinedCharacter(let definition):
        newState.definitionState.currentDefinition = definition
        newState.viewState.readerDisplayType = .normal
    case .onSynthesizedAudio(var data):
        newState.audioState.currentPlaybackTime = 0
        newState.definitionState.currentDefinition = nil

        var newStory = newState.storyState.currentStory
        let chapterIndex = newStory?.currentChapterIndex ?? 0
        newStory?.chapters[chapterIndex].audioData = data.audioData
        newStory?.chapters[chapterIndex].audioSpeed = newState.settingsState.speechSpeed
        newStory?.chapters[chapterIndex].audioVoice = newState.settingsState.voice
        newStory?.chapters[chapterIndex].timestampData = data.wordTimestamps
        newState.storyState.currentStory = newStory

        if let player = data.audioData.createAVPlayer() {
            newState.audioState.audioPlayer = player
        }
    case .updateShowDefinition(let isShowing):
        newState.settingsState.isShowingDefinition = isShowing
    case .updateShowEnglish(let isShowing):
        newState.settingsState.isShowingEnglish = isShowing
    case .updateShowingCreateStoryScreen(let isShowing):
        newState.viewState.isShowingCreateStoryScreen = isShowing
    case .updateShowingSettings(let isShowing):
        newState.viewState.isShowingSettingsScreen = isShowing
    case .updateShowingStoryListView(let isShowing):
        newState.viewState.isShowingStoryListView = isShowing
    case .updateSelectGenre(let genre, let isSelected):
        if isSelected {
            if !newState.createStoryState.selectedGenres.contains(genre) {
                newState.createStoryState.selectedGenres.append(genre)
            }
        } else {
            newState.createStoryState.selectedGenres.removeAll(where: { $0 == genre })
        }
    case .selectChapter(var story, let chapterIndex):
        newState.viewState.isShowingStoryListView = false
        story.lastUpdated = .now
        if let chapter = story.chapters[safe: chapterIndex] {
            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }
            story.currentChapterIndex = chapterIndex
        }
        newState.storyState.currentStory = story

        newState.storyState.sentenceIndex = 0
        newState.settingsState.language = story.language

        if let data = newState.storyState.currentChapterAudioData,
           let player = data.createAVPlayer() {
            newState.audioState.audioPlayer = player
        }
    case .onSelectedChapter:
        if let language = newState.storyState.currentStory?.language {
            newState.settingsState.language = language
        }
    case .generateChapter:
        newState.viewState.readerDisplayType = .loading
    case .generateNewStory:
        newState.viewState.readerDisplayType = .loading
        newState.viewState.isShowingStoryListView = false
        newState.viewState.isShowingCreateStoryScreen = false
    case .failedToGenerateNewStory:
        newState.viewState.readerDisplayType = .failedToGenerateStory
    case .failedToGenerateChapter:
        newState.viewState.readerDisplayType = .failedToGenerateChapter
    case .updateSentenceIndex(let index):
        newState.storyState.sentenceIndex = index
    case .playAudio(let time):
        newState.audioState.isPlayingAudio = true
        if let time {
            newState.audioState.currentPlaybackTime = time
        }
    case .pauseAudio:
        newState.audioState.isPlayingAudio = false
    case .stopAudio:
        newState.audioState.isPlayingAudio = false
        newState.audioState.currentPlaybackTime = 0
    case .updatePlayTime:
        newState.audioState.currentPlaybackTime = newState.audioState.audioPlayer.currentTime().seconds
        if let index = newState.currentSpokenWord?.sentenceIndex {
            newState.storyState.sentenceIndex = index
        }
    case .selectWord(let timestampData):
        newState.audioState.currentPlaybackTime = timestampData.time
    case .goToNextChapter:
        var newStory = newState.storyState.currentStory
        newStory?.currentChapterIndex += 1
        newState.storyState.currentStory = newStory
        if let data = newState.storyState.currentChapterAudioData,
           let player = data.createAVPlayer() {
            newState.audioState.audioPlayer = player
        }
    case .refreshChapterView:
        newState.viewState.chapterViewId = UUID()
    case .refreshDefinitionView:
        newState.viewState.definitionViewId = UUID()
    case .refreshTranslationView:
        newState.viewState.translationViewId = UUID()
    case .selectStorySetting(let setting):
        newState.createStoryState.selectedStorySetting = setting
    case .selectVoice(let voice):
        newState.settingsState.voice = voice
    case .updateDifficulty(let difficulty):
        newState.settingsState.difficulty = difficulty
    case .updateLanguage(let language):
        newState.settingsState.language = language
        if let voice = language.voices.first {
            newState.settingsState.voice = voice
        }
    case .saveStory,
            .failedToSaveStory,
            .failedToLoadStories,
            .failedToPlayAudio,
            .failedToDefineCharacter,
            .loadStories,
            .synthesizeAudio,
            .onPlayedAudio,
            .deleteStory,
            .failedToDeleteStory,
            .failedToSaveAppSettings,
            .failedToLoadAppSettings,
            .loadAppSettings,
            .saveAppSettings,
            .playWord,
            .finishedPlayingWord:
        break
    }

    return newState
}
