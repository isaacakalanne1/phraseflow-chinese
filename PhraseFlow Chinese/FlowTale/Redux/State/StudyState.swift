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
    var currentChapter: Chapter?
    var isAudioPlaying: Bool
    
    init(audioPlayer: AVPlayer = AVPlayer(),
         currentChapter: Chapter? = nil,
         isAudioPlaying: Bool = false) {
        self.audioPlayer = audioPlayer
        self.currentChapter = currentChapter
        self.isAudioPlaying = isAudioPlaying
    }
}
