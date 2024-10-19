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

    case selectStory(Story)
    case generateNewStory(categories: [Category])
    case onGeneratedStory(Story)
    case failedToGenerateNewStory
    case generateNewPassage(story: Story)
    case onGeneratedNewPassage(passage: String)
    case failedToGenerateNewPassage

    case generateChapter(passage: String)
    case onGeneratedChapter(chapter: Chapter)
    case failedToGenerateChapter

    case saveStory(Story)
    case failedToSaveStory

    case selectChapter(Int)

    case loadStories
    case onLoadedStories([Story])
    case failedToLoadStories

    case goToNextSentence
    case goToPreviousSentence

    case synthesizeAudio(Sentence)
    case onSynthesizedAudio((wordTimestamps: [(word: String,
                                               time: Double,
                                               textOffset: Int,
                                               wordLength: Int)],
                             audioData: Data))
    case playAudio(time: Double?)
    case onPlayedAudio
    case failedToPlayAudio

    case defineCharacter(String)
    case onDefinedCharacter(String)
    case failedToDefineCharacter

    case updateShowPinyin(Bool)
    case updateShowMandarin(Bool)
    case updateShowEnglish(Bool)

    case updateSelectedWordIndices(startIndex: Int, endIndex: Int)
    case clearSelectedWord

    case updateSpeechSpeed(SpeechSpeed)
}
