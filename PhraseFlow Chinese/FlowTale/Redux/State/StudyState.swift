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

    init(audioPlayer: AVPlayer = AVPlayer(),
         currentChapter: Chapter? = nil) {
        self.audioPlayer = audioPlayer
        self.currentChapter = currentChapter
    }
}
