//
//  AVPlayer+Play.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import AVKit

public extension AVPlayer {
    func playAudio(fromSeconds: Double = 0,
                   toSeconds: Double = .infinity,
                   playRate: Float? = nil) async {
        let fromTime = CMTime(seconds: fromSeconds, preferredTimescale: 60000)
        await seek(to: fromTime, toleranceBefore: .zero, toleranceAfter: .zero)
        let toTime = CMTime(seconds: toSeconds, preferredTimescale: 60000)
        currentItem?.forwardPlaybackEndTime = toTime
        if let playRate {
            playImmediately(atRate: playRate)
        } else {
            play()
        }
    }
}
