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
    var audioPlayer: AudioPlayer { get }
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
    func isNearEndOfTrack(endTimeOfLastWord: Double) -> Bool
    func getCurrentPlaybackTime() -> Double
    func updatePlaybackRate(_ playRate: Float)
}
