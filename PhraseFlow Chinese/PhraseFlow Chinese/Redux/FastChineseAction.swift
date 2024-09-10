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
    case fetchAllPhrases
    case onFetchedAllPhrases([Phrase])
    case failedToFetchAllPhrases

    case saveAllPhrases
    case failedToSaveAllPhrases
    case fetchSavedPhrases
    case clearAllLearningPhrases

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
}
