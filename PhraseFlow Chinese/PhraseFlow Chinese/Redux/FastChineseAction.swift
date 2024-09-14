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
    case onFetchedNewPhrases([Phrase])
    case removePhrase(Phrase)
    case failedToFetchNewPhrases

    case saveAllPhrases
    case failedToSaveAllPhrases
    case fetchSavedPhrases
    case onFetchedSavedPhrases([Phrase])
    case failedToFetchSavedPhrases

    case submitAnswer
    case goToNextPhrase
    case preloadAudio
    case failedToPreloadAudio

    case updatePhrasesAudio([Phrase], audioDataList: [Data])
    case failedToUpdatePhraseAudio

    case segmentPhrasesAudio([Phrase], urlList: [URL])
    case onSegmentedPhrasesAudio([Phrase], segmentsList: [[Segment]])
    case failedToSegmentPhraseAudioAtIndex

    case revealAnswer
    case playAudio
    case playAudioFromIndex(Int)
    case failedToPlayAudioFromIndex
    case updateAudioPlayer(AVAudioPlayer)
    case onUpdatedAudioPlayer
    case failedToUpdateAudioPlayer

    case defineCharacter(String)
    case onDefinedCharacter(String)
    case failedToDefineCharacter

    case updateSpeechSpeed(SpeechSpeed)
    case updatePracticeMode(PracticeMode)

    case fetchChineseDictionary
    case onFetchedChineseDictionary([String: Phrase])
    case failedToFetchChineseDictionary
}
