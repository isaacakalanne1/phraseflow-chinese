//
//  AudioEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import AVKit
import Combine

public struct AudioEnvironment: AudioEnvironmentProtocol {
    public var appSoundSubject: CurrentValueSubject<AppSound?, Never>
    public var playMusicSubject: CurrentValueSubject<(music: MusicType, volume: MusicVolume)?, Never>
    public var stopMusicSubject: CurrentValueSubject<Bool, Never>
    public var setMusicVolumeSubject: CurrentValueSubject<MusicVolume?, Never>
    public var musicFinishedSubject: CurrentValueSubject<Bool, Never>
    public var audioDelegate: AudioDelegate
    
    public init() {
        appSoundSubject = .init(nil)
        playMusicSubject = .init(nil)
        stopMusicSubject = .init(false)
        setMusicVolumeSubject = .init(nil)
        musicFinishedSubject = .init(false)
        audioDelegate = AudioDelegate {
            // This will be set up properly after initialization
        }
        
        // Set up the delegate callback after initialization
        audioDelegate = AudioDelegate { [musicFinishedSubject] in
            musicFinishedSubject.send(true)
        }
    }
    
    // MARK: - AudioPlayer Wrapper Methods
    
    public func playSound(_ sound: AppSound) {
        appSoundSubject.send(sound)
    }

    public func playMusic(
        _ music: MusicType,
        volume: MusicVolume
    ) throws {
        playMusicSubject.send((music: music, volume: volume))
    }
    
    public func stopMusic() {
        stopMusicSubject.send(true)
    }
    
    public func setMusicVolume(_ volume: MusicVolume) {
        setMusicVolumeSubject.send(volume)
    }
    
}
