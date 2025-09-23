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
    case playMusic(music: MusicType, volume: MusicVolume)
    case stopMusic
    case setMusicVolume(MusicVolume)
}
