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
    let currentTime = state.audioState.audioPlayer.currentTime().seconds

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
            let playRate = state.settingsState.speechSpeed.playRate

            if isPlaybackAtEnd(state) {
                await state.audioState.audioPlayer.playAudio(playRate: playRate)
            } else if let timestamp {
                await state.audioState.audioPlayer.playAudio(fromSeconds: timestamp,
                                                             playRate: playRate)
            }
            
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .playWord(let word):
            await state.audioState.audioPlayer.playAudio(fromSeconds: word.time,
                                                         toSeconds: word.time + word.duration,
                                                         playRate: state.settingsState.speechSpeed.playRate)
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .playSound:
            if state.settingsState.shouldPlaySound {
                state.appAudioState.audioPlayer.play()
            }
            return nil
            
        case .playMusic:
            state.musicAudioState.audioPlayer.play()
            
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .musicTrackFinished(let nextMusicType):
            return .audioAction(.playMusic(nextMusicType))
            
        case .stopMusic:
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .pauseAudio:
            state.audioState.audioPlayer.pause()
            if let chapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(chapter))
            }
            return nil
            
        case .updatePlayTime:
            let currentTime = state.audioState.audioPlayer.currentTime().seconds
            if let lastSentence = state.storyState.currentChapter?.sentences.last,
               let lastWordTime = lastSentence.timestamps.last?.time,
               let lastWordDuration = lastSentence.timestamps.last?.duration,
               currentTime > lastWordTime + lastWordDuration {
                return .audioAction(.pauseAudio)
            }
            return nil
            
        case .setMusicVolume(let volume):
            state.musicAudioState.audioPlayer.setVolume(volume.float, fadeDuration: 0.2)
            return nil
            
        case .onPlayedAudio:
            return nil
        }
    default:
        return nil
    }
}
