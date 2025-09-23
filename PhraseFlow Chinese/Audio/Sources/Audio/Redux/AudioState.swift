//
//  AudioState.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import AVKit
import Foundation

struct AudioState: Equatable {
    var chapterAudioPlayer: AVPlayer
    var musicAudioPlayer: AVAudioPlayer
    var appSoundAudioPlayer: AVAudioPlayer
    
    init(
        chapterAudioPlayer: AVPlayer = .init(),
        musicAudioPlayer: AVAudioPlayer = .init(),
        appSoundAudioPlayer: AVAudioPlayer = .init()
    ) {
        self.chapterAudioPlayer = chapterAudioPlayer
        self.musicAudioPlayer = musicAudioPlayer
        self.appSoundAudioPlayer = appSoundAudioPlayer
    }
}
