//
//  AudioEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Combine
import AVKit
import Speech

public protocol AudioEnvironmentProtocol {
    func playChapterAudio(from time: Double?, rate: Float) async
    func pauseChapterAudio()
    public func playWord(startTime: Double,
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
