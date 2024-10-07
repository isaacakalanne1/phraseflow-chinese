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
    
    case fetchNewPhrases(PhraseCategory)
    case onFetchedNewPhrases([Sentence])
    case removePhrase(Sentence)
    case failedToFetchNewPhrases

    case saveSentences
    case failedToSaveSentences
    case fetchSavedPhrases
    case onFetchedSavedPhrases([Sentence])
    case failedToFetchSavedPhrases

    case submitAnswer
    case goToNextPhrase
    case preloadAudio
    case failedToPreloadAudio

    case updatePhrasesAudio([Sentence], audioDataList: [Data])
    case failedToUpdatePhraseAudio

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
