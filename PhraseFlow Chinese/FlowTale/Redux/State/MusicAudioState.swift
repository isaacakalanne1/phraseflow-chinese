//
//  MusicAudioState.swift
//  FlowTale
//
//  Created by iakalann on 04/01/2025.
//

import Foundation
import AVKit

struct MusicAudioState {
    var volume: MusicVolume = .normal
    var audioPlayer = AVAudioPlayer()
    var currentMusicType: MusicType

    var isNearEndOfTrack: Bool {
        guard audioPlayer.duration > 0 else { return false }
        // Consider near end if within last 1 second of track
        return audioPlayer.currentTime >= audioPlayer.duration - 3
    }

    init(audioPlayer: AVAudioPlayer = AVAudioPlayer(),
         currentMusicType: MusicType = .whispersOfTheForest) {
        self.audioPlayer = audioPlayer
        self.currentMusicType = currentMusicType
    }
}
