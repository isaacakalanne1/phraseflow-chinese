//
//  AudioMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit
import AVKit

private func isPlaybackAtEnd(_ state: FlowTaleState) -> Bool {
    let currentTime = state.audioState.chapterAudioPlayer.currentTime().seconds

    guard let lastSentence = state.storyState.currentChapter?.sentences.last,
          let lastWordTime = lastSentence.timestamps.last?.time,
          let lastWordDuration = lastSentence.timestamps.last?.duration else {
        return false
    }
    let endTime = lastWordTime + lastWordDuration - 0.5
    
    return currentTime >= endTime
}

let audioMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .audioAction(let audioAction):
        switch audioAction {
        case .playAudio(let timestamp):
            let playRate = state.audioState.speechSpeed.playRate

            if isPlaybackAtEnd(state) {
                await state.audioState.chapterAudioPlayer.playAudio(playRate: playRate)
            } else if let timestamp {
                await state.audioState.chapterAudioPlayer.playAudio(fromSeconds: timestamp,
                                                             playRate: playRate)
            }
            
            environment.audioEnvironment.clearCurrentDefinition()
            
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .playWord(let word):
            await state.audioState.chapterAudioPlayer.playAudio(fromSeconds: word.time,
                                                         toSeconds: word.time + word.duration,
                                                         playRate: state.audioState.speechSpeed.playRate)
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .playSound:
            if state.settingsState.shouldPlaySound {
                state.audioState.appSoundAudioPlayer.play()
            }
            return nil
            
        case .playMusic:
            state.audioState.musicAudioPlayer.play()
            environment.audioEnvironment.settingsEnvironment.setIsPlayingMusic(true)
            
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .musicTrackFinished(let nextMusicType):
            return .audioAction(.playMusic(nextMusicType))
            
        case .stopMusic:
            environment.audioEnvironment.settingsEnvironment.setIsPlayingMusic(false)
            
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .pauseAudio:
            state.audioState.chapterAudioPlayer.pause()
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .updatePlayTime:
            let currentTime = state.audioState.chapterAudioPlayer.currentTime().seconds
            if let lastSentence = state.storyState.currentChapter?.sentences.last,
               let lastWordTime = lastSentence.timestamps.last?.time,
               let lastWordDuration = lastSentence.timestamps.last?.duration,
               currentTime > lastWordTime + lastWordDuration {
                return .audioAction(.pauseAudio)
            }
            return nil
            
        case .setMusicVolume(let volume):
            state.audioState.musicAudioPlayer.setVolume(volume.float, fadeDuration: 0.2)
            return nil
            
        case .updateSpeechSpeed(let speed):
            environment.audioEnvironment.saveSpeechSpeed(speed)
            return nil
            
        case .onPlayedAudio:
            return nil
        }
    default:
        return nil
    }
}
