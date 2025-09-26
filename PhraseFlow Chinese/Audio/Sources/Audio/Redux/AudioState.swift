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
    var currentMusicType: MusicType?
    var currentVolume: MusicVolume = .normal
    var isPlayingMusic: Bool = false
    
    init(
        musicAudioPlayer: AVAudioPlayer = .init(),
        appSoundAudioPlayer: AVAudioPlayer = .init(),
        currentMusicType: MusicType? = nil,
        currentVolume: MusicVolume = .normal,
        isPlayingMusic: Bool = false
    ) {
        self.musicAudioPlayer = musicAudioPlayer
        self.appSoundAudioPlayer = appSoundAudioPlayer
        self.currentMusicType = currentMusicType
        self.currentVolume = currentVolume
        self.isPlayingMusic = isPlayingMusic
    }
    
    var nextMusicType: MusicType? {
        guard let current = currentMusicType else { return MusicType.allCases.first }
        let allTypes = MusicType.allCases
        guard let currentIndex = allTypes.firstIndex(of: current) else { return allTypes.first }
        let nextIndex = (currentIndex + 1) % allTypes.count
        return allTypes[nextIndex]
    }
    
    var previousMusicType: MusicType? {
        guard let current = currentMusicType else { return MusicType.allCases.last }
        let allTypes = MusicType.allCases
        guard let currentIndex = allTypes.firstIndex(of: current) else { return allTypes.last }
        let previousIndex = currentIndex == 0 ? allTypes.count - 1 : currentIndex - 1
        return allTypes[previousIndex]
    }
}
