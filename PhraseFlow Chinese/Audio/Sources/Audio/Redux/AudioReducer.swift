//
//  AudioReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
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
        
    case .playMusic(let music):
        if let url = music.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = 0
            player.volume = MusicVolume.normal.float
            newState.currentMusicType = music
            newState.musicAudioPlayer = player
            // Settings state changes handled at FlowTaleReducer level
        }
        
    case .setMusicVolume(let volume):
        newState.volume = volume
        
    case .stopMusic:
        // Settings state changes handled at FlowTaleReducer level
        newState.musicAudioPlayer.stop()
        newState.currentMusicType = .whispersOfTheForest
        
    case .playAudio(let time):
        // Definition and story state changes handled at FlowTaleReducer level
        newState.isPlayingAudio = true
        
    case .pauseAudio:
        newState.isPlayingAudio = false
        
    case .updatePlayTime:
        // Story state changes handled at FlowTaleReducer level
        break
        
    case .updateSpeechSpeed(let speed):
        newState.speechSpeed = speed
        if newState.chapterAudioPlayer.rate != 0 {
            newState.chapterAudioPlayer.rate = speed.playRate
        }
        
    case .playWord,
            .musicTrackFinished,
            .onPlayedAudio:
        break
    }

    return newState
}
