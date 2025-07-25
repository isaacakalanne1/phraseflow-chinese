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
    case .showSnackBar(let type):
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbar
        }
        return nil
        
    case .checkDeviceVolumeZero:
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            return nil
        }
        return audioSession.outputVolume == 0.0 ? .showSnackBar(.deviceVolumeZero) : nil
        
    case .hideSnackbar:
        return nil
    }
}
