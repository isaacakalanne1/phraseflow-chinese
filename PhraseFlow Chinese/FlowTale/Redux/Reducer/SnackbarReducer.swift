//
//  SnackbarReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import AVKit

let snackbarReducer: Reducer<FlowTaleState, SnackbarAction> = { state, action in
    var newState = state

    switch action {
    case .showSnackBar(let type),
          .showSnackBarThenSaveStory(let type, _):
        if let url = type.sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appAudioState.audioPlayer = player
        }
        newState.snackBarState.type = type
        newState.snackBarState.isShowing = true
        
    case .hideSnackbar:
        newState.snackBarState.isShowing = false
        
    case .hideSnackbarThenSaveStoryAndSettings:
        newState.snackBarState.isShowing = false

    case .checkDeviceVolumeZero:
        break
    }

    return newState
}
