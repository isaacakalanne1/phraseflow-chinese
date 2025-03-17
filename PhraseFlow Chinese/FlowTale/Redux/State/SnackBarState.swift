//
//  SnackBarState.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import AVKit
import Foundation

struct SnackBarState {
    var audioPlayer = AVAudioPlayer()

    var type: SnackBarType? = nil
    var isShowing: Bool {
        type != nil
    }
}
