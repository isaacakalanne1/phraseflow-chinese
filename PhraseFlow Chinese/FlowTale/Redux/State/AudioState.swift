//
//  AudioState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation
import AVKit

struct AudioState {
    var audioPlayer = AVPlayer()
    var isPlayingAudio = false

    init(audioPlayer: AVPlayer = AVPlayer(),
         isPlayingAudio: Bool = false) {
        self.audioPlayer = audioPlayer
        self.isPlayingAudio = isPlayingAudio
    }
}
