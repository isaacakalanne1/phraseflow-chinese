//
//  FastChineseAction.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

enum FastChineseAction {
    case updateShowingCreateStoryScreen(isShowing: Bool)
    case updateShowingSettings(isShowing: Bool)
    case updateShowingStoryListView(isShowing: Bool)
    case updateSelectGenre(Genre, isSelected: Bool)
    case updateSentenceIndex(Int)

    case generateNewStory
    case onGeneratedStory(Story)
    case failedToGenerateNewStory

    case generateChapter(story: Story)
    case onGeneratedChapter(Story)
    case failedToGenerateChapter

    case saveStory(Story)
    case failedToSaveStory

    case saveStoryAndSettings(Story)
    case onSavedStoryAndSettings
    case failedToSaveStoryAndSettings

    case deleteStory(Story)
    case onDeletedStory
    case failedToDeleteStory

    case selectChapter(Story, chapterIndex: Int)
    case onSelectedChapter

    case loadStories
    case onLoadedStories([Story])
    case failedToLoadStories

    case loadDefinitions
    case onLoadedDefinitions([Definition])
    case failedToLoadDefinitions

    case synthesizeAudio(Chapter, voice: Voice, isForced: Bool)
    case onSynthesizedAudio((wordTimestamps: [WordTimeStampData],
                             audioData: Data))
    case playAudio(time: Double?)
    case pauseAudio
    case stopAudio
    case onPlayedAudio
    case failedToSynthesizeAudio
    case updatePlayTime

    case defineCharacter(WordTimeStampData, shouldForce: Bool)
    case playWord(WordTimeStampData)
    case finishedPlayingWord
    case onDefinedCharacter(Definition)
    case failedToDefineCharacter
    case saveDefinitions
    case onSavedDefinitions
    case failedToSaveDefinitions

    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)

    case updateSpeechSpeed(SpeechSpeed)
    case updateDifficulty(Difficulty)
    case updateLanguage(Language)
    case selectWord(WordTimeStampData)

    case goToNextChapter
    case refreshChapterView
    case refreshDefinitionView
    case refreshTranslationView
    case refreshStoryListView

    case selectStorySetting(StorySetting?)
    
    case selectVoice(Voice)

    case loadAppSettings
    case onLoadedAppSettings(SettingsState)
    case failedToLoadAppSettings

    case saveAppSettings
    case failedToSaveAppSettings
}
