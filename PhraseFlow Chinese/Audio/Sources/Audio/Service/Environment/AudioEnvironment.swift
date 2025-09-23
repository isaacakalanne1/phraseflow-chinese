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
    public let audioPlayer: AudioPlayer
    
    public init() {
        self.audioPlayer = AudioPlayer()
        appSoundSubject = .init(nil)
    }
    
    public var isPlayingMusic: Bool {
        audioPlayer.musicAudioPlayer?.isPlaying ?? false
    }
    
    // MARK: - AudioPlayer Wrapper Methods
    
    public func setChapterAudioData(_ audioData: Data) async {
        await audioPlayer.setChapterAudioData(audioData)
    }
    
    public func playChapterAudio(from time: Double?, rate: Float) async {
        await audioPlayer.playAudio(from: time, playRate: rate)
    }
    
    public func pauseChapterAudio() {
        audioPlayer.pauseAudio()
    }
    
    public func playWord(startTime: Double,
                         duration: Double,
                         playRate: Float) async {
        await audioPlayer.playSection(startTime: startTime,
                                      duration: duration,
                                      playRate: playRate)
    }
    
    public func playSound(_ sound: AppSound) {
        appSoundSubject.send(sound)
    }

    public func playMusic(
        _ music: MusicType,
        volume: MusicVolume
    ) throws {
        try audioPlayer.playMusic(music, volume: volume)
    }
    
    public func stopMusic() {
        audioPlayer.stopMusic()
    }
    
    public func setMusicVolume(_ volume: MusicVolume) {
        audioPlayer.setMusicVolume(volume)
    }
    
    public func isNearEndOfTrack(endTimeOfLastWord: Double) -> Bool {
        audioPlayer.isNearEndOfTrack(endTimeOfLastWord: endTimeOfLastWord)
    }
    
    public func getCurrentPlaybackTime() -> Double {
        audioPlayer.getCurrentPlaybackTime()
    }
    
    public func updatePlaybackRate(_ playRate: Float) {
        audioPlayer.updatePlaybackRate(playRate)
    }
}
