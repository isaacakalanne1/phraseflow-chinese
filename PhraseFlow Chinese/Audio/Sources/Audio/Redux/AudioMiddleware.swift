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
    case .setChapterAudioData(let audioData):
        if let player = await audioData.createAVPlayer() {
            return .onCreatedChapterPlayer(player)
        }
        return nil
    case .onCreatedChapterPlayer:
        return nil
    case .playChapterAudio(let time, let rate):
        if let time = time {
            await state.chapterAudioPlayer.playAudio(fromSeconds: time, playRate: rate)
        } else {
            await state.chapterAudioPlayer.playAudio(playRate: rate)
        }
        return nil
    case .pauseChapterAudio:
        state.chapterAudioPlayer.pause()
        return nil
    case .playWord(let startTime, let duration, let playRate):
        await state.chapterAudioPlayer.playAudio(
            fromSeconds: startTime,
            toSeconds: startTime + duration,
            playRate: playRate
        )
        return nil
    case .playMusic:
        if !state.isPlayingMusic {
            state.musicAudioPlayer.play()
        }
        return nil
    case .stopMusic:
        state.musicAudioPlayer.stop()
        return nil
    case .setMusicVolume:
        return nil
    case .updatePlaybackRate(let playRate):
        if state.chapterAudioPlayer.rate != 0 {
            state.chapterAudioPlayer.rate = playRate
        }
        return nil
    }
}
