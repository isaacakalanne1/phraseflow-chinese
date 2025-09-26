//
//  AudioEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import AVKit

public protocol AudioEnvironmentProtocol {
    var appSoundSubject: CurrentValueSubject<AppSound?, Never> { get }
    var playMusicSubject: CurrentValueSubject<(music: MusicType, volume: MusicVolume)?, Never> { get }
    var stopMusicSubject: CurrentValueSubject<Bool, Never> { get }
    var setMusicVolumeSubject: CurrentValueSubject<MusicVolume?, Never> { get }
    var musicFinishedSubject: CurrentValueSubject<Bool, Never> { get }
    var audioDelegate: AudioDelegate { get }
    func playSound(_ sound: AppSound)
    func playMusic(_ music: MusicType, volume: MusicVolume) throws
    func stopMusic()
    func setMusicVolume(_ volume: MusicVolume)
}
