//
//  FastChineseAction.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

enum FastChineseAction {
    case generateNewChapter
    case onGeneratedNewChapter([Sentence])
    case failedToGenerateNewChapter

    case saveSentences
    case failedToSaveSentences

    case loadChapter(generationInfo: ChapterGenerationInfo, chapterIndex: Int)
    case onLoadedChapter(Chapter)
    case failedToLoadChapter

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
