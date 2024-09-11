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

    case updatePhraseAudio(Phrase, audioData: Data)
    case failedToUpdatePhraseAudio

    case segmentPhraseAudio(Phrase, url: URL)
    case onSegmentedPhraseAudio(Phrase, segments: [Segment])
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
}
