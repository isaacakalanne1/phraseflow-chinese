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
    }
    return newState
}
