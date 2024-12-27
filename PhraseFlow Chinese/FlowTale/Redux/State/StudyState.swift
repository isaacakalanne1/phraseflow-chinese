//
//  StudyState.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation
import AVKit

struct StudyState {
    var audioPlayer = AVPlayer()
    var currentPlaybackTime: TimeInterval = 0
    var isPlayingAudio = false

    init(audioPlayer: AVPlayer = AVPlayer(),
         currentPlaybackTime: TimeInterval = 0,
         isPlayingAudio: Bool = false) {
        self.audioPlayer = audioPlayer
        self.currentPlaybackTime = currentPlaybackTime
        self.isPlayingAudio = isPlayingAudio
    }
}
