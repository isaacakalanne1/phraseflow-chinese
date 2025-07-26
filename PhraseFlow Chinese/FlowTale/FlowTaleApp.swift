//
//  FlowTaleApp.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import AVKit
import SwiftUI

@main
struct FlowTaleApp: App {

    init() { }

    var body: some Scene {
        WindowGroup {
            FlowTaleRootView()
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                }
        }
    }
}
