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

    case fetchAllLearningPhrases
    case onFetchedAllLearningPhrases([Phrase])

    case goToNextPhrase
    case preloadAudio
    case failedToPreloadAudio

    case updatePhraseAudioAtIndex(index: Int, audioData: Data)
    case failedToUpdatePhraseAudioAtIndex

    case transcribePhraseAudioAtIndex(index: Int, url: URL)
    case failedToSegmentPhraseAudioAtIndex
    
    case onSegmentedPhraseAudioAtIndex(index: Int, segments: [Segment])

    case revealAnswer
    case playAudio
    case updateAudioPlayer(AVAudioPlayer)
    case onUpdatedAudioPlayer
    case failedToUpdateAudioPlayer
}
