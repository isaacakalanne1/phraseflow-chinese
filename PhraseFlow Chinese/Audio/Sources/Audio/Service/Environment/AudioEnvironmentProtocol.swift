//
//  AudioEnvironmentProtocol.swift
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

public protocol AudioEnvironmentProtocol {
    var appSoundSubject: CurrentValueSubject<AppSound?, Never> { get }
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var clearDefinitionSubject: CurrentValueSubject<Void, Never> { get }
    var chapterSubject: CurrentValueSubject<Void, Never> { get }
    
    func playSound(_ sound: AppSound)
    func saveSpeechSpeed(_ speed: SpeechSpeed)
    func clearCurrentDefinition()
    
    // AudioPlayer wrapper methods
    func playChapterAudio(from time: Double?, rate: Float) async
    func pauseChapterAudio()
    func playWord(_ word: WordTimeStampData, rate: Float) async
    func playSound(_ sound: AppSound, shouldPlay: Bool)
    func playMusic(_ music: MusicType, volume: MusicVolume) throws -> AVAudioPlayer
    func stopMusic()
    func setMusicVolume(_ volume: MusicVolume)
    func isNearEndOfTrack(chapter: Chapter?) -> Bool
    func getCurrentPlaybackTime() -> Double
    func updatePlaybackRate(_ playRate: Float)
}
