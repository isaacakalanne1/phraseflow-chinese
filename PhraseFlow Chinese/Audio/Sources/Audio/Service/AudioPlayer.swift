//
//  AudioPlayer.swift
//  FlowTale
//
//  Created by iakalann on 19/07/2025.
//

import Foundation
import AVKit

public class AudioPlayer {
    public var chapterAudioPlayer: AVPlayer
    public var musicAudioPlayer: AVAudioPlayer?
    private var appSoundAudioPlayer: AVAudioPlayer?
    
    init() {
        self.chapterAudioPlayer = AVPlayer()
        self.musicAudioPlayer = nil
        self.appSoundAudioPlayer = nil
    }
    
    // MARK: - Chapter Audio Methods
    
    func setChapterAudioData(_ audioData: Data) async {
        if let player = await audioData.createAVPlayer() {
            chapterAudioPlayer = player
        }
    }
    
    func playAudio(from time: Double? = nil, playRate: Float) async {
        if let time = time {
            await chapterAudioPlayer.playAudio(fromSeconds: time, playRate: playRate)
        } else {
            await chapterAudioPlayer.playAudio(playRate: playRate)
        }
    }
    
    func pauseAudio() {
        chapterAudioPlayer.pause()
    }
    
    func playSection(startTime: Double,
                     duration: Double,
                     playRate: Float) async {
        await chapterAudioPlayer.playAudio(fromSeconds: startTime,
                                         toSeconds: startTime + duration,
                                         playRate: playRate)
    }
    
    func isNearEndOfTrack(endTimeOfLastWord: Double) -> Bool {
        chapterAudioPlayer.currentTime().seconds >= endTimeOfLastWord
    }
    
    func getCurrentPlaybackTime() -> Double {
        return chapterAudioPlayer.currentTime().seconds
    }
    
    func updatePlaybackRate(_ playRate: Float) {
        if chapterAudioPlayer.rate != 0 {
            chapterAudioPlayer.rate = playRate
        }
    }
    
    // MARK: - Music Methods
    
    @discardableResult
    func playMusic(_ musicType: MusicType, volume: MusicVolume) throws -> AVAudioPlayer {
        guard let url = musicType.fileURL else {
            throw AudioPlayerError.musicFileNotFound
        }
        
        let player = try AVAudioPlayer(contentsOf: url)
        player.numberOfLoops = -1
        player.volume = volume.float
        self.musicAudioPlayer = player
        player.play()
        
        return player
    }
    
    func stopMusic() {
        musicAudioPlayer?.stop()
    }
    
    func setMusicVolume(_ volume: MusicVolume) {
        musicAudioPlayer?.setVolume(volume.float, fadeDuration: 0.2)
    }
    
    // MARK: - Sound Effect Methods
    
    func playSound(_ sound: AppSound) throws {
        guard let url = sound.fileURL else {
            throw AudioPlayerError.soundFileNotFound
        }
        let player = try AVAudioPlayer(contentsOf: url)
        player.volume = 0.7
        self.appSoundAudioPlayer = player
        player.play()
    }
}

enum AudioPlayerError: Error {
    case musicFileNotFound
    case soundFileNotFound
}
