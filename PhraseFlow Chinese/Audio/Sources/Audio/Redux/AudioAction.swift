//
//  AudioAction.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import Foundation
import AVKit

enum AudioAction: Equatable, Sendable {
    case playSound(AppSound)
    case setChapterAudioData(Data)
    case onCreatedChapterPlayer(AVPlayer)
    case playChapterAudio(time: Double?, rate: Float)
    case pauseChapterAudio
    case playWord(startTime: Double, duration: Double, playRate: Float)
    case playMusic(music: MusicType, volume: MusicVolume)
    case stopMusic
    case setMusicVolume(MusicVolume)
    case updatePlaybackRate(Float)
}
