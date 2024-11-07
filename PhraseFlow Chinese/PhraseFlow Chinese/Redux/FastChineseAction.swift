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

    case selectStory(Story)
    case generateNewStory(genres: [Genre])
    case onGeneratedStory(Story)
    case failedToGenerateNewStory

    case generateChapter(story: Story)
    case onGeneratedChapter(ChapterResponse)
    case failedToGenerateChapter

    case saveStory(Story)
    case failedToSaveStory

    case deleteStory(Story)
    case failedToDeleteStory

    case selectChapter(Story, chapterIndex: Int)

    case loadStories
    case onLoadedStories([Story])
    case failedToLoadStories

    case synthesizeAudio(Chapter, voice: Voice, isForced: Bool)
    case onSynthesizedAudio((wordTimestamps: [WordTimeStampData],
                             audioData: Data))
    case playAudio(time: Double?)
    case pauseAudio
    case stopAudio
    case onPlayedAudio
    case failedToPlayAudio
    case updatePlayTime

    case defineCharacter(WordTimeStampData, shouldForce: Bool)
    case playWord(WordTimeStampData)
    case finishedPlayingWord
    case onDefinedCharacter(Definition)
    case failedToDefineCharacter

    case updateShowPinyin(Bool)
    case updateShowDefinition(Bool)
    case updateShowEnglish(Bool)

    case updateSpeechSpeed(SpeechSpeed)
    case selectWord(WordTimeStampData)

    case goToNextChapter
    case refreshChapterView
    case refreshDefinitionView
    case refreshTranslationView

    case selectStorySetting(StorySetting?)
    
    case selectVoice(Voice)

    case loadAppSettings
    case onLoadedAppSettings(AppSettings)
    case failedToLoadAppSettings

    case saveAppSettings
    case failedToSaveAppSettings
}
