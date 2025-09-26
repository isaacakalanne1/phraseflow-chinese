//
//  AudioState.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import AVKit
import Foundation

struct AudioState: Equatable {
    var musicAudioPlayer: AVAudioPlayer
    var appSoundAudioPlayer: AVAudioPlayer
    var currentMusic: MusicType
    
    init(
        currentMusic: MusicType = .whispersOfTranquility,
        musicAudioPlayer: AVAudioPlayer = .init(),
        appSoundAudioPlayer: AVAudioPlayer = .init()
    ) {
        self.currentMusic = currentMusic
        self.musicAudioPlayer = musicAudioPlayer
        self.appSoundAudioPlayer = appSoundAudioPlayer
    }
    
    var isPlayingMusic: Bool {
        musicAudioPlayer.isPlaying
    }
}
