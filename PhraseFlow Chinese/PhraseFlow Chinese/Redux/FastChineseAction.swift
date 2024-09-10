//
//  FastChineseAction.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import SwiftWhisper

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
    case failedToTranscribePhraseAudioAtIndex
    
    case onTranscribedPhraseAudioAtIndex(index: Int, segments: [Segment])
}
