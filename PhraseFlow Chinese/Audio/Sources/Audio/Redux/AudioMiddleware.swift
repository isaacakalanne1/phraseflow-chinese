//
//  AudioMiddleware.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import Foundation
import ReduxKit

@MainActor
let audioMiddleware: Middleware<AudioState, AudioAction,  AudioEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .playSound:
        state.appSoundAudioPlayer.play()
        return nil
    case .playMusic:
        state.musicAudioPlayer.delegate = environment.audioDelegate
        state.musicAudioPlayer.play()
        return nil
    case .stopMusic:
        state.musicAudioPlayer.stop()
        return nil
    case .pauseMusic:
        state.musicAudioPlayer.pause()
        return nil
    case .resumeMusic:
        state.musicAudioPlayer.play()
        return nil
    case .nextMusic:
        state.musicAudioPlayer.stop()
        state.musicAudioPlayer.delegate = environment.audioDelegate
        state.musicAudioPlayer.play()
        return nil
    case .previousMusic:
        state.musicAudioPlayer.stop()
        state.musicAudioPlayer.delegate = environment.audioDelegate
        state.musicAudioPlayer.play()
        return nil
    case .setMusicVolume:
        return nil
    case .musicFinished:
        state.musicAudioPlayer.delegate = environment.audioDelegate
        state.musicAudioPlayer.play()
        return nil
    }
}
