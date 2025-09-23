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
    var chapterAudioDataSubject: CurrentValueSubject<Data?, Never> { get }
    var playChapterAudioSubject: CurrentValueSubject<(time: Double?, rate: Float)?, Never> { get }
    var pauseChapterAudioSubject: CurrentValueSubject<Bool, Never> { get }
    var playWordSubject: CurrentValueSubject<(startTime: Double, duration: Double, playRate: Float)?, Never> { get }
    var playMusicSubject: CurrentValueSubject<(music: MusicType, volume: MusicVolume)?, Never> { get }
    var stopMusicSubject: CurrentValueSubject<Bool, Never> { get }
    var setMusicVolumeSubject: CurrentValueSubject<MusicVolume?, Never> { get }
    var updatePlaybackRateSubject: CurrentValueSubject<Float?, Never> { get }
    func setChapterAudioData(_ audioData: Data) async
    func playChapterAudio(from time: Double?, rate: Float) async
    func pauseChapterAudio()
    func playWord(startTime: Double,
                  duration: Double,
                  playRate: Float) async
    func playSound(_ sound: AppSound)
    func playMusic(_ music: MusicType, volume: MusicVolume) throws
    func stopMusic()
    func setMusicVolume(_ volume: MusicVolume)
    func updatePlaybackRate(_ playRate: Float)
}
