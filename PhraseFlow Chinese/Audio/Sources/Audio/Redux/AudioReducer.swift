//
//  AudioReducer.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import SwiftUI
import ReduxKit
import AVKit

@MainActor
let audioReducer: Reducer<AudioState, AudioAction> = { state, action in
    var newState = state
    switch action {
    case .playSound(let sound):
        if let url = sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appSoundAudioPlayer = player
        }
    case .playMusic(let music, let volume):
        if let url = music.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = 0
            player.volume = volume.float
            player.prepareToPlay()
            newState.musicAudioPlayer = player
            newState.currentMusicType = music
            newState.currentVolume = volume
            newState.isPlayingMusic = true
        }
    case .stopMusic:
        newState.currentMusicType = nil
        newState.isPlayingMusic = false
        break
    case .pauseMusic:
        newState.isPlayingMusic = false
        break
    case .resumeMusic:
        newState.isPlayingMusic = true
        break
    case .nextMusic:
        if let nextMusic = newState.nextMusicType,
           let url = nextMusic.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = 0
            player.volume = newState.currentVolume.float
            player.prepareToPlay()
            newState.musicAudioPlayer = player
            newState.currentMusicType = nextMusic
            newState.isPlayingMusic = true
        }
    case .previousMusic:
        if let previousMusic = newState.previousMusicType,
           let url = previousMusic.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = 0
            player.volume = newState.currentVolume.float
            player.prepareToPlay()
            newState.musicAudioPlayer = player
            newState.currentMusicType = previousMusic
            newState.isPlayingMusic = true
        }
    case .setMusicVolume(let volume):
        newState.musicAudioPlayer.setVolume(volume.float, fadeDuration: 0.2)
        newState.currentVolume = volume
    case .musicFinished:
        if let nextMusic = newState.nextMusicType,
           let url = nextMusic.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = 0
            player.volume = newState.currentVolume.float
            player.prepareToPlay()
            newState.musicAudioPlayer = player
            newState.currentMusicType = nextMusic
            newState.isPlayingMusic = true
        }
    }
    return newState
}
