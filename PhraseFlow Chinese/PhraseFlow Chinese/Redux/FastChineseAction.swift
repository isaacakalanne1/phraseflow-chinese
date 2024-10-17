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
    case updateSelectCategory(Category, isSelected: Bool)

    case generateNewStory(categories: [Category])
    case failedToGenerateNewStory
    case generateNewChapter(story: Story, index: Int)
    case onGeneratedNewChapter(Chapter)
    case failedToGenerateNewChapter

    case saveStory(Story?)
    case failedToSaveStory

    case loadStory(generationInfo: StoryGenerationInfo)
    case onLoadedStory(Story)
    case failedToLoadStory

    case goToNextSentence

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

    case updateSpeechSpeed(SpeechSpeed)
}
