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
    func saveSpeechSpeed(_ speed: SpeechSpeed)
    
    // AudioPlayer wrapper methods
    func playChapterAudio(from time: Double?, rate: Float) async
    func pauseChapterAudio()
    func playWord(_ word: WordTimeStampData, rate: Float) async
    func playSound(_ sound: AppSound)
    func playMusic(_ music: MusicType, volume: MusicVolume) throws
    func stopMusic()
    func setMusicVolume(_ volume: MusicVolume)
    func isNearEndOfTrack(chapter: Chapter?) -> Bool
    func getCurrentPlaybackTime() -> Double
    func updatePlaybackRate(_ playRate: Float)
}
