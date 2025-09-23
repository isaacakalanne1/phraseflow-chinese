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
    public var chapterAudioDataSubject: CurrentValueSubject<Data?, Never>
    public var playChapterAudioSubject: CurrentValueSubject<(time: Double?, rate: Float)?, Never>
    public var pauseChapterAudioSubject: CurrentValueSubject<Bool, Never>
    public var playWordSubject: CurrentValueSubject<(startTime: Double, duration: Double, playRate: Float)?, Never>
    public var playMusicSubject: CurrentValueSubject<(music: MusicType, volume: MusicVolume)?, Never>
    public var stopMusicSubject: CurrentValueSubject<Bool, Never>
    public var setMusicVolumeSubject: CurrentValueSubject<MusicVolume?, Never>
    public var updatePlaybackRateSubject: CurrentValueSubject<Float?, Never>
    
    public init() {
        appSoundSubject = .init(nil)
        chapterAudioDataSubject = .init(nil)
        playChapterAudioSubject = .init(nil)
        pauseChapterAudioSubject = .init(false)
        playWordSubject = .init(nil)
        playMusicSubject = .init(nil)
        stopMusicSubject = .init(false)
        setMusicVolumeSubject = .init(nil)
        updatePlaybackRateSubject = .init(nil)
    }
    
    // MARK: - AudioPlayer Wrapper Methods
    
    public func setChapterAudioData(_ audioData: Data) async {
        chapterAudioDataSubject.send(audioData)
    }
    
    public func playChapterAudio(from time: Double?, rate: Float) async {
        playChapterAudioSubject.send((time: time, rate: rate))
    }
    
    public func pauseChapterAudio() {
        pauseChapterAudioSubject.send(true)
    }
    
    public func playWord(startTime: Double,
                         duration: Double,
                         playRate: Float) async {
        playWordSubject.send((startTime: startTime, duration: duration, playRate: playRate))
    }
    
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
    
    public func updatePlaybackRate(_ playRate: Float) {
        updatePlaybackRateSubject.send(playRate)
    }
}
