//
//  AudioState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation
import AVKit
import Settings

struct AudioState {
    var chapterAudioPlayer = AVPlayer()
    var musicAudioPlayer = AVAudioPlayer()
    var appSoundAudioPlayer = AVAudioPlayer()
    var isPlayingAudio = false
    var volume: MusicVolume = .normal
    var currentMusicType: MusicType
    var speechSpeed: SpeechSpeed = .normal

    var isNearEndOfTrack: Bool {
        guard musicAudioPlayer.duration > 0 else { return false }
        // Consider near end if within last 3 seconds of track
        return musicAudioPlayer.currentTime >= musicAudioPlayer.duration - 3
    }

    init(chapterAudioPlayer: AVPlayer = AVPlayer(),
         musicAudioPlayer: AVAudioPlayer = AVAudioPlayer(),
         appSoundAudioPlayer: AVAudioPlayer = AVAudioPlayer(),
         isPlayingAudio: Bool = false,
         currentMusicType: MusicType = .whispersOfTheForest,
         speechSpeed: SpeechSpeed = .normal) {
        self.chapterAudioPlayer = chapterAudioPlayer
        self.musicAudioPlayer = musicAudioPlayer
        self.appSoundAudioPlayer = appSoundAudioPlayer
        self.isPlayingAudio = isPlayingAudio
        self.currentMusicType = currentMusicType
        self.speechSpeed = speechSpeed
    }
}
