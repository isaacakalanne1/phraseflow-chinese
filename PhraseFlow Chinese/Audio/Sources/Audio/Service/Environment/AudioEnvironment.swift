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
    let appSoundSubject = CurrentValueSubject<AppSound?, Never>(nil)
    let clearDefinitionSubject = CurrentValueSubject<Void, Never>(())
    let chapterSubject = CurrentValueSubject<Void, Never>(())
    let settingsEnvironment: SettingsEnvironmentProtocol
    private let audioPlayer: AudioPlayer
    
    init(settingsEnvironment: SettingsEnvironmentProtocol) {
        self.settingsEnvironment = settingsEnvironment
        self.audioPlayer = AudioPlayer()
    }
    
    func playSound(_ sound: AppSound) {
        appSoundSubject.send(sound)
    }
    
    func saveSpeechSpeed(_ speed: SpeechSpeed) {
        settingsEnvironment.saveSpeechSpeed(speed)
    }
    
    func clearCurrentDefinition() {
        clearDefinitionSubject.send(())
    }
    
    // MARK: - AudioPlayer Wrapper Methods
    
    func playChapterAudio(from time: Double?, rate: Float) async {
        await audioPlayer.playAudio(from: time, playRate: rate)
        clearCurrentDefinition()
        chapterSubject.send(())
    }
    
    func pauseChapterAudio() {
        audioPlayer.pauseAudio()
        chapterSubject.send(())
    }
    
    func playWord(_ word: WordTimeStampData, rate: Float) async {
        await audioPlayer.playWord(word, playRate: rate)
        chapterSubject.send(())
    }
    
    func playSound(_ sound: AppSound, shouldPlay: Bool) {
        guard shouldPlay else { return }
        try? audioPlayer.playSound(sound, shouldPlaySounds: shouldPlay)
    }
    
    @discardableResult
    func playMusic(_ music: MusicType, volume: MusicVolume) throws -> AVAudioPlayer {
        let player = try audioPlayer.playMusic(music, volume: volume)
        settingsEnvironment.setIsPlayingMusic(true)
        chapterSubject.send(())
        return player
    }
    
    func stopMusic() {
        audioPlayer.stopMusic()
        settingsEnvironment.setIsPlayingMusic(false)
        chapterSubject.send(())
    }
    
    func setMusicVolume(_ volume: MusicVolume) {
        audioPlayer.setMusicVolume(volume)
    }
    
    func isNearEndOfTrack(chapter: Chapter?) -> Bool {
        return audioPlayer.isNearEndOfTrack(chapter: chapter)
    }
    
    func getCurrentPlaybackTime() -> Double {
        return audioPlayer.getCurrentPlaybackTime()
    }
    
    func updatePlaybackRate(_ playRate: Float) {
        audioPlayer.updatePlaybackRate(playRate)
    }
}
