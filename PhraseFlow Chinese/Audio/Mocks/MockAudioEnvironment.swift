//
//  MockAudioEnvironment.swift
//  Audio
//
//  Created by Isaac Akalanne on 19/09/2025.
//

import Audio
import Foundation

enum MockAudioEnvironmentError: Error {
    case genericError
}

public class MockAudioEnvironment: AudioEnvironmentProtocol {
    
    public init() {

    }
    
    var isPlayingMusicResult = false
    public var isPlayingMusic: Bool {
        isPlayingMusicResult
    }
    
    var setChapterAudioDataSpy: Data?
    var setChapterAudioDataCalled = false
    public func setChapterAudioData(_ audioData: Data) async {
        setChapterAudioDataSpy = audioData
        setChapterAudioDataCalled = true
    }
    
    
    var playChapterAudioFromTimeSpy: Double?
    var playChapterAudioRateSpy: Float?
    var playChapterAudioCalled = false
    public func playChapterAudio(
        from time: Double?,
        rate: Float
    ) async {
        playChapterAudioFromTimeSpy = time
        playChapterAudioRateSpy = rate
        playChapterAudioCalled = true
    }
    
    var pauseChapterAudioCalled = false
    public func pauseChapterAudio() {
        pauseChapterAudioCalled = true
    }
    
    var playWordStartTimeSpy: Double?
    var playWordDurationSpy: Double?
    var playWordPlayRateSpy: Float?
    var playWordCalled = false
    public func playWord(
        startTime: Double,
        duration: Double,
        playRate: Float
    ) async {
        playWordStartTimeSpy = startTime
        playWordDurationSpy = duration
        playWordPlayRateSpy = playRate
        playWordCalled = true
    }
    
    var playSoundSpy: AppSound?
    var playSoundCalled = false
    public func playSound(_ sound: AppSound) {
        playSoundSpy = sound
        playSoundCalled = true
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
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var stopMusicCalled = false
    public func stopMusic() {
        stopMusicCalled = true
    }
    
    var setMusicVolumeSpy: MusicVolume?
    var setMusicVolumeCalled = false
    public func setMusicVolume(_ volume: MusicVolume) {
        setMusicVolumeSpy = volume
        setMusicVolumeCalled = true
    }
    
    var isNearEndOfTrackSpy: Double?
    var isNearEndOfTrackCalled = false
    var isNearEndOfTrackResult = false
    public func isNearEndOfTrack(endTimeOfLastWord: Double) -> Bool {
        isNearEndOfTrackSpy = endTimeOfLastWord
        isNearEndOfTrackCalled = true
        return isNearEndOfTrackResult
    }
    
    var getCurrentPlaybackTimeCalled = false
    var getCurrentPlaybackTimeResult: Double = 0
    public func getCurrentPlaybackTime() -> Double {
        getCurrentPlaybackTimeCalled = true
        return getCurrentPlaybackTimeResult
    }
    
    var updatePlaybackRateSpy: Float?
    var updatePlaybackRateCalled = false
    public func updatePlaybackRate(_ playRate: Float) {
        updatePlaybackRateSpy = playRate
        updatePlaybackRateCalled = true
    }
}
