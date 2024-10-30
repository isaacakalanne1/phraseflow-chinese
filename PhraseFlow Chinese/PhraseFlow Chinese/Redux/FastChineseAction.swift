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
    case updateSelectCategory(Category, isSelected: Bool)
    case updateSentenceIndex(Int)

    case selectStory(Story)
    case generateNewStory(categories: [Category])
    case onGeneratedStory(Story)
    case failedToGenerateNewStory

    case generateChapter(previousChapter: Chapter)
    case onGeneratedChapter(ChapterResponse)
    case failedToGenerateChapter

    case saveStory(Story)
    case failedToSaveStory

    case selectChapter(Story, chapterIndex: Int)

    case loadStories
    case onLoadedStories([Story])
    case failedToLoadStories

    case synthesizeAudio(Chapter, isForced: Bool)
    case onSynthesizedAudio((wordTimestamps: [WordTimeStampData],
                             audioData: Data))
    case playAudio(time: Double?)
    case pauseAudio
    case stopAudio
    case onPlayedAudio
    case failedToPlayAudio
    case updatePlayTime

    case defineCharacter(WordTimeStampData, shouldForce: Bool)
    case onDefinedCharacter(Definition)
    case failedToDefineCharacter

    case updateShowPinyin(Bool)
    case updateShowMandarin(Bool)
    case updateShowEnglish(Bool)

    case updateSpeechSpeed(SpeechSpeed)
    case selectWord(WordTimeStampData)

    case goToNextChapter
}
