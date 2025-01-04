//
//  MusicAudioState.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation
import AVKit

struct MusicAudioState {
    var audioPlayer = AVAudioPlayer()

    init(audioPlayer: AVAudioPlayer = AVAudioPlayer()) {
        self.audioPlayer = audioPlayer
    }
}
