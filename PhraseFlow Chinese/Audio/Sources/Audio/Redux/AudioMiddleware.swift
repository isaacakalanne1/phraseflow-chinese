//
//  AudioMiddleware.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import Foundation
import ReduxKit
import Moderation

@MainActor
let audioMiddleware: Middleware<AudioState, AudioAction,  AudioEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .playSound:
        state.appSoundAudioPlayer.play()
        return nil
    case .playMusic:
        state.musicAudioPlayer.play()
        return nil
    case .stopMusic:
        state.musicAudioPlayer.stop()
        return nil
    case .setMusicVolume:
        return nil
    }
}
