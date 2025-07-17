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
        if let wordTime = time,
           var currentChapter = newState.storyState.currentChapter {
            currentChapter.currentPlaybackTime = wordTime
            newState.storyState.currentChapter = currentChapter
            if let storyId = currentChapter.storyId as UUID?,
               let chapters = newState.storyState.storyChapters[storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyState.storyChapters[storyId]?[index] = currentChapter
            }
        }
        
    case .pauseAudio:
        newState.audioState.isPlayingAudio = false
        
    case .updatePlayTime:
        if var currentChapter = newState.storyState.currentChapter {
            currentChapter.currentPlaybackTime = newState.audioState.audioPlayer.currentTime().seconds
            newState.storyState.currentChapter = currentChapter
            if let storyId = currentChapter.storyId as UUID?,
               let chapters = newState.storyState.storyChapters[storyId],
               let index = chapters.firstIndex(where: { $0.id == currentChapter.id }) {
                newState.storyState.storyChapters[storyId]?[index] = currentChapter
            }
        }
        
    case .playWord,
            .musicTrackFinished,
            .onPlayedAudio:
        break
    }

    return newState
}
