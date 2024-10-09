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

    case playAudio(Sentence)
    case failedToPlayAudio

    case defineCharacter(String)
    case onDefinedCharacter(String)
    case failedToDefineCharacter

    case updateSpeechSpeed(SpeechSpeed)
}
