//
//  StudyState.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation
import AVKit

struct StudyState {
    var audioPlayer: AVPlayer
    var sentenceAudioPlayer: AVPlayer
    var isAudioPlaying: Bool
    
    init(audioPlayer: AVPlayer = AVPlayer(),
         sentenceAudioPlayer: AVPlayer = AVPlayer(),
         isAudioPlaying: Bool = false) {
        self.audioPlayer = audioPlayer
        self.sentenceAudioPlayer = sentenceAudioPlayer
        self.isAudioPlaying = isAudioPlaying
    }
}
