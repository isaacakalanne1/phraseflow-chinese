//
//  MockAudioEnvironment.swift
//  Audio
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Audio
import Foundation
import Combine
import AVKit

enum MockAudioEnvironmentError: Error {
    case genericError
}

public class MockAudioEnvironment: AudioEnvironmentProtocol {
    public var appSoundSubject: CurrentValueSubject<AppSound?, Never> = .init(nil)
    public var playMusicSubject: CurrentValueSubject<(music: MusicType, volume: MusicVolume)?, Never> = .init(nil)
    public var stopMusicSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var setMusicVolumeSubject: CurrentValueSubject<MusicVolume?, Never> = .init(nil)
    public var musicFinishedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public var audioDelegate: AudioDelegate
    
    public init() {
        audioDelegate = AudioDelegate {
            // Mock implementation
        }
    }
    
    var playSoundSpy: AppSound?
    var playSoundCalled = false
    public func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
        appSoundSubject.send(sound)
    }
    
    var playMusicTypeSpy: MusicType?
    var playMusicVolumeSpy: MusicVolume?
    var playMusicCalled = false
    var playMusicResult: Result<Void, MockAudioEnvironmentError> = .success(())
    public func playMusic(
        _ music: MusicType,
        volume: MusicVolume
    ) throws {
        playMusicTypeSpy = music
        playMusicVolumeSpy = volume
        playMusicCalled = true
        switch playMusicResult {
        case .success(let success):
            playMusicSubject.send((music: music, volume: volume))
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var stopMusicCalled = false
    public func stopMusic() {
        stopMusicCalled = true
        stopMusicSubject.send(true)
    }
    
    var setMusicVolumeSpy: MusicVolume?
    var setMusicVolumeCalled = false
    public func setMusicVolume(_ volume: MusicVolume) {
        setMusicVolumeSpy = volume
        setMusicVolumeCalled = true
        setMusicVolumeSubject.send(volume)
    }
}
