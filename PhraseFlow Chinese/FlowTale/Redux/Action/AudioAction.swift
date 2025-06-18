//
//  AudioAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum AudioAction {
    case playAudio(time: Double?)
    case pauseAudio
    case playWord(WordTimeStampData, story: Story?)
    case playSound(AppSound)
    case playMusic(MusicType)
    case musicTrackFinished(MusicType)
    case stopMusic
    case updatePlayTime
    case setMusicVolume(MusicVolume)
    case onPlayedAudio
}