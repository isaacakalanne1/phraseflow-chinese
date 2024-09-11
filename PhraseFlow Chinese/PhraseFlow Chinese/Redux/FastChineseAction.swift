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
    case fetchNewPhrases(PhraseCategory)
    case onFetchedNewPhrases([Phrase])
    case failedToFetchAllPhrases

    case saveAllPhrases
    case failedToSaveAllPhrases
    case fetchSavedPhrases
    case onFetchedSavedPhrases([Phrase])
    case failedToFetchSavedPhrases
    case clearAllLearningPhrases

    case submitAnswer(String)
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
    case updateAudioPlayer(AVAudioPlayer)
    case onUpdatedAudioPlayer
    case failedToUpdateAudioPlayer

    case updatePhraseToLearning(Phrase)
    case removePhraseFromLearning(Phrase)

    case updateSpeechSpeed(SpeechSpeed)
    case updatePracticeMode(PracticeMode)
}
