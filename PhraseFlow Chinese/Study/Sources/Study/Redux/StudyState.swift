//
//  StudyState.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation
import AVKit

struct StudyState {
    var audioPlayer: AVPlayer
    var sentenceAudioPlayer: AVPlayer
    var isAudioPlaying: Bool
    var displayStatus: StudyDisplayStatus = .wordShown

    init(
        audioPlayer: AVPlayer = AVPlayer(),
        sentenceAudioPlayer: AVPlayer = AVPlayer(),
        isAudioPlaying: Bool = false,
        displayStatus: StudyDisplayStatus = .wordShown
    ) {
        self.audioPlayer = audioPlayer
        self.sentenceAudioPlayer = sentenceAudioPlayer
        self.isAudioPlaying = isAudioPlaying
        self.displayStatus = displayStatus
    }
}
