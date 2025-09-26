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
            player.numberOfLoops = -1
            player.volume = volume.float
            newState.musicAudioPlayer = player
        }
    case .stopMusic:
        break
    case .setMusicVolume(let volume):
        newState.musicAudioPlayer.setVolume(volume.float, fadeDuration: 0.2)
    }
    return newState
}
