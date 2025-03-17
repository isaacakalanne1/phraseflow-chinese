//
//  SnackBarReducer.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import AVKit
import ReduxKit

let snackBarReducer: Reducer<SnackBarState, SnackBarAction> = { state, action in

    var newState = state
    switch action {
    case .showSnackBar(let type):
        if let url = type.sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.audioPlayer = player
        }
        newState.type = type
    case .hideSnackbar:
        newState.type = nil
    case .showSnackBarThenSaveStory(let type, _):
        newState.type = type
    }

    return newState
}
