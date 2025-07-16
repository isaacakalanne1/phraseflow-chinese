//
//  VideoBackgroundView.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import AVKit
import SwiftUI

struct VideoBackgroundView: UIViewControllerRepresentable {
    var player: AVPlayer
    var autoPlay: Bool

    init(player: AVPlayer, autoPlay: Bool = false) {
        self.player = player
        self.autoPlay = autoPlay
    }

    class Coordinator: NSObject {
        var parent: VideoBackgroundView
        var readyToPlayObserver: Any?

        init(_ parent: VideoBackgroundView) {
            self.parent = parent
            super.init()
        }

        @objc func playerItemDidReachEnd(notification _: Notification) {
            parent.player.seek(to: CMTime.zero)
            parent.player.play()
        }

        func setupReadyObserver() {
            if let currentItem = parent.player.currentItem {
                readyToPlayObserver = currentItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
                    guard self?.parent.autoPlay == true else { return }

                    if item.status == .readyToPlay {
                        self?.parent.player.play()

                        // Remove observer once we've started playing
                        if let observer = self?.readyToPlayObserver {
                            self?.readyToPlayObserver = nil
                            NotificationCenter.default.removeObserver(observer)
                        }
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsVideoFrameAnalysis = false
        controller.player = player
        controller.showsPlaybackControls = false
        controller.requiresLinearPlayback = true
        controller.videoGravity = .resizeAspectFill
        controller.updatesNowPlayingInfoCenter = false

        // Configure player for looping
        player.actionAtItemEnd = .none

        // Setup ready observer to start playing when ready
        context.coordinator.setupReadyObserver()

        // Add observer for video end to loop
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        // Apply horizontal flip transformation
        DispatchQueue.main.async {
            if let playerLayer = controller.view.layer.sublayers?.compactMap({ $0 as? AVPlayerLayer }).first {
                playerLayer.transform = CATransform3DMakeScale(-1, 1, 1)
            }
        }

        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context _: Context) {
        // Ensure flip is applied if view is refreshed
        DispatchQueue.main.async {
            if let playerLayer = controller.view.layer.sublayers?.compactMap({ $0 as? AVPlayerLayer }).first {
                playerLayer.transform = CATransform3DMakeScale(-1, 1, 1)
            }
        }
    }

    static func dismantleUIViewController(_ controller: AVPlayerViewController, coordinator: Coordinator) {
        // Remove observers when view is destroyed
        if let _ = coordinator.readyToPlayObserver {
            coordinator.readyToPlayObserver = nil
        }

        NotificationCenter.default.removeObserver(
            coordinator,
            name: .AVPlayerItemDidPlayToEndTime,
            object: controller.player?.currentItem
        )
    }
}
