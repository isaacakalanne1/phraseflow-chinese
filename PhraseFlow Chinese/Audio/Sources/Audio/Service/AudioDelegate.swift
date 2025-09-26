//
//  AudioDelegate.swift
//  Audio
//
//  Created by Isaac Akalanne on 26/09/2025.
//

import Foundation
import AVKit

public class AudioDelegate: NSObject, AVAudioPlayerDelegate {
    private let onMusicFinished: () -> Void
    
    public init(onMusicFinished: @escaping () -> Void) {
        self.onMusicFinished = onMusicFinished
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            onMusicFinished()
        }
    }
}