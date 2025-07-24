//
//  AudioEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import Settings
import AVKit
import Speech
import TextGeneration

public struct AudioEnvironment: AudioEnvironmentProtocol {
    let settingsEnvironment: SettingsEnvironmentProtocol
    private let audioPlayer: AudioPlayer
    
    public init(settingsEnvironment: SettingsEnvironmentProtocol) {
        self.settingsEnvironment = settingsEnvironment
        self.audioPlayer = AudioPlayer()
        if let settings = try? settingsEnvironment.loadAppSettings(),
           settings.isPlayingMusic {
            try? playMusic(.whispersOfTranquility, volume: .normal)
        }
    }
    
    public func saveSpeechSpeed(_ speed: SpeechSpeed) {
        settingsEnvironment.saveSpeechSpeed(speed)
    }
    
    // MARK: - AudioPlayer Wrapper Methods
    
    public func playChapterAudio(from time: Double?, rate: Float) async {
        await audioPlayer.playAudio(from: time,
                                    playRate: rate)
    }
    
    public func pauseChapterAudio() {
        audioPlayer.pauseAudio()
    }
    
    public func playWord(_ word: WordTimeStampData, rate: Float) async {
        await audioPlayer.playWord(word, playRate: rate)
    }
    
    public func playSound(_ sound: AppSound) {
        try? audioPlayer.playSound(sound)
    }

    public func playMusic(
        _ music: MusicType,
        volume: MusicVolume
    ) throws {
        try audioPlayer.playMusic(music, volume: volume)
        settingsEnvironment.setIsPlayingMusic(true)
    }
    
    public func stopMusic() {
        audioPlayer.stopMusic()
        settingsEnvironment.setIsPlayingMusic(false)
    }
    
    public func setMusicVolume(_ volume: MusicVolume) {
        audioPlayer.setMusicVolume(volume)
    }
    
    public func isNearEndOfTrack(chapter: Chapter?) -> Bool {
        audioPlayer.isNearEndOfTrack(chapter: chapter)
    }
    
    public func getCurrentPlaybackTime() -> Double {
        audioPlayer.getCurrentPlaybackTime()
    }
    
    public func updatePlaybackRate(_ playRate: Float) {
        audioPlayer.updatePlaybackRate(playRate)
    }
}
