//
//  SnackBarMiddleware.swift
//  SnackBar
//
//  Created by iakalann on 15/06/2025.
//

import AVKit
import Foundation
import ReduxKit

@MainActor
public let snackBarMiddleware: Middleware<SnackBarState, SnackBarAction, SnackBarEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .setType:
        return state.type == .none ? .hideSnackbar : .showSnackbar
        
    case .showSnackbar:
        try? await Task.sleep(for: .seconds(state.type.showDuration))
        return .hideSnackbar
        
    case .checkDeviceVolumeZero:
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            return nil
        }
        return audioSession.outputVolume == 0.0 ? .setType(.deviceVolumeZero) : nil
        
    case .hideSnackbar:
        return nil
    }
}
