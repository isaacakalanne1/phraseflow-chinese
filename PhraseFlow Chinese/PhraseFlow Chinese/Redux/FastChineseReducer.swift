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
    case .onGeneratedChapter(let chapterResponse):
        var newStory = newState.storyState.currentStory
        newStory?.latestStorySummary = chapterResponse.latestStorySummary

        let chapter = Chapter(storyTitle: "Story title here", sentences: chapterResponse.sentences)
        if newStory?.chapters.isEmpty == true {
            newStory?.chapters = [chapter]
        } else {
            newStory?.chapters.append(chapter)
        }
        let chapters = newStory?.chapters
        newStory?.currentChapterIndex = (chapters?.count ?? 1) - 1
        newState.storyState.currentStory = newStory

        newState.audioPlayer = AVPlayer()
        newState.viewState = .normal
        newState.storyState.sentenceIndex = 0
        newState.isShowingCreateStoryScreen = false
    case .onGeneratedStory(let story):
        newState.storyState.currentStory = story
        newState.viewState = .normal
    case .onLoadedStories(let stories):
        newState.storyState.savedStories = stories
        let currentStory = stories.first
        if newState.storyState.currentStory == nil,
           !stories.isEmpty {
            newState.storyState.currentStory = currentStory
            if let data = newState.storyState.currentChapterAudioData,
               let player = data.createAVPlayer() {
                newState.audioPlayer = player
            }
        }

    case .updateSpeechSpeed(let speed):
        newState.settingsState.speechSpeed = speed
    case .defineCharacter(let wordTimeStampData, let shouldForce):
        newState.tappedWord = wordTimeStampData
        newState.viewState = .defining
    case .onDefinedCharacter(let definition):
        newState.currentDefinition = definition
        newState.viewState = .normal
    case .onSynthesizedAudio(let data):
        newState.currentPlaybackTime = 0
        newState.currentDefinition = nil

        var newStory = newState.storyState.currentStory
        let chapterIndex = newStory?.currentChapterIndex ?? 0
        newStory?.chapters[chapterIndex].audioData = data.audioData
        newStory?.chapters[chapterIndex].audioSpeed = newState.settingsState.speechSpeed
        newStory?.chapters[chapterIndex].audioVoice = newState.settingsState.voice
        newStory?.chapters[chapterIndex].timestampData = data.wordTimestamps
        newState.storyState.currentStory = newStory

        if let player = data.audioData.createAVPlayer() {
            newState.audioPlayer = player
        }
    case .updateShowPinyin(let isShowing):
        newState.settingsState.isShowingPinyin = isShowing
    case .updateShowDefinition(let isShowing):
        newState.settingsState.isShowingDefinition = isShowing
    case .updateShowEnglish(let isShowing):
        newState.settingsState.isShowingEnglish = isShowing
    case .updateShowingCreateStoryScreen(let isShowing):
        newState.isShowingCreateStoryScreen = isShowing
    case .updateShowingSettings(let isShowing):
        newState.isShowingSettingsScreen = isShowing
    case .updateShowingStoryListView(let isShowing):
        newState.isShowingStoryListView = isShowing
    case .updateSelectGenre(let genre, let isSelected):
        if isSelected {
            if !newState.selectedGenres.contains(genre) {
                newState.selectedGenres.append(genre)
            }
        } else {
            newState.selectedGenres.removeAll(where: { $0 == genre })
        }
    case .selectStory(let story):
        newState.storyState.sentenceIndex = 0
        newState.storyState.currentStory = story
        newState.isShowingStoryListView = false
        if let data = newState.storyState.currentChapterAudioData,
           let player = data.createAVPlayer() {
            newState.audioPlayer = player
        }
    case .selectChapter(let story, let chapterIndex):
        newState.storyState.currentStory = story
        newState.storyState.sentenceIndex = 0
        newState.isShowingStoryListView = false
        if let chaptersCount = newState.storyState.currentStory?.chapters.count,
           chapterIndex > -1,
           chapterIndex < chaptersCount {
            newState.storyState.currentStory?.currentChapterIndex = chapterIndex
        }
        if let data = newState.storyState.currentChapterAudioData,
           let player = data.createAVPlayer() {
            newState.audioPlayer = player
        }
    case .generateChapter:
        newState.viewState = .loading
    case .generateNewStory:
        newState.viewState = .loading
        newState.isShowingStoryListView = false
        newState.isShowingCreateStoryScreen = false
    case .failedToGenerateNewStory:
        newState.viewState = .failedToGenerateStory
    case .failedToGenerateChapter:
        newState.viewState = .failedToGenerateChapter
    case .updateSentenceIndex(let index):
        newState.storyState.sentenceIndex = index
    case .playAudio(let time):
        newState.isPlayingAudio = true
        if let time {
            newState.currentPlaybackTime = time
        }
    case .pauseAudio:
        newState.isPlayingAudio = false
    case .stopAudio:
        newState.isPlayingAudio = false
        newState.currentPlaybackTime = 0
    case .updatePlayTime:
        newState.currentPlaybackTime = newState.audioPlayer.currentTime().seconds
    case .selectWord(let timestampData):
        newState.currentPlaybackTime = timestampData.time
    case .goToNextChapter:
        var newStory = newState.storyState.currentStory
        newStory?.currentChapterIndex += 1
        newState.storyState.currentStory = newStory
        if let data = newState.storyState.currentChapterAudioData,
           let player = data.createAVPlayer() {
            newState.audioPlayer = player
        }
    case .refreshChapterView:
        newState.chapterViewId = UUID()
    case .refreshDefinitionView:
        newState.definitionViewId = UUID()
    case .refreshTranslationView:
        newState.translationViewId = UUID()
    case .selectStorySetting(let setting):
        newState.selectedStorySetting = setting
    case .selectVoice(let voice):
        newState.settingsState.voice = voice
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
