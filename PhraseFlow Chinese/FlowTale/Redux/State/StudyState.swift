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

    init(audioPlayer: AVPlayer = AVPlayer()) {
        self.audioPlayer = audioPlayer
    }
}
