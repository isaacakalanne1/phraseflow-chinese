//
//  AudioState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 16/11/2024.
//

import Foundation
import AVKit

struct AudioState {
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
