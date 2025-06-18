//
//  AudioReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import AVKit

let audioReducer: Reducer<FlowTaleState, AudioAction> = { state, action in
    var newState = state

    switch action {
    case .playSound(let sound):
        if let url = sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appAudioState.audioPlayer = player
        }
        
    case .playMusic(let music):
        if let url = music.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.numberOfLoops = 0
            player.volume = MusicVolume.normal.float
            newState.musicAudioState.currentMusicType = music
            newState.musicAudioState.audioPlayer = player
            newState.settingsState.isPlayingMusic = true
        }
        
    case .setMusicVolume(let volume):
        newState.musicAudioState.volume = volume
        
    case .stopMusic:
        newState.settingsState.isPlayingMusic = false
        newState.musicAudioState.audioPlayer.stop()
        newState.musicAudioState.currentMusicType = .whispersOfTheForest
        
    case .playAudio(let time):
        newState.definitionState.currentDefinition = nil
        newState.audioState.isPlayingAudio = true
        if let wordTime = time {
            newState.storyState.currentStory?.currentPlaybackTime = wordTime
        }
        
    case .pauseAudio:
        newState.audioState.isPlayingAudio = false
        
    case .updatePlayTime:
        newState.storyState.currentStory?.currentPlaybackTime = newState.audioState.audioPlayer.currentTime().seconds
        
    case .playWord(let word, _):
        newState.storyState.currentStory?.currentPlaybackTime = word.time
        
    case .musicTrackFinished:
        break
        
    case .onPlayedAudio:
        break
    }

    return newState
}