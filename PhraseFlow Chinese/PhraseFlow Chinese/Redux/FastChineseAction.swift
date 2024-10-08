//
//  FastChineseAction.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import SwiftWhisper
import AVKit

enum FastChineseAction {
    case updateUserInput(String)
    
    case generateNewChapter
    case onGeneratedNewChapter([Sentence])
    case failedToGenerateNewChapter

    case saveSentences
    case failedToSaveSentences

    case loadChapter(generationInfo: ChapterGenerationInfo, chapterIndex: Int)
    case onLoadedChapter(Chapter)
    case failedToLoadChapter

    case submitAnswer
    case goToNextSentence
    case preloadAudio
    case failedToPreloadAudio

    case updateSentencesAudio([Sentence], audioDataList: [Data])
    case failedToUpdateSentencesAudio

    case revealAnswer
    case playAudio
    case updateAudioPlayer(AVAudioPlayer)
    case onUpdatedAudioPlayer
    case failedToUpdateAudioPlayer

    case defineCharacter(String)
    case onDefinedCharacter(String)
    case failedToDefineCharacter

    case updateSpeechSpeed(SpeechSpeed)
    case updatePracticeMode(PracticeMode)
}
