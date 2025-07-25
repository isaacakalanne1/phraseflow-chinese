//
//  SnackBarMiddleware.swift
//  SnackBar
//
//  Created by iakalann on 15/06/2025.
//

import AVKit
import Foundation
import ReduxKit

public struct SnackBarMiddleware: Middleware {
    public typealias State = SnackBarState
    public typealias Action = SnackBarAction
    public typealias Environment = SnackBarEnvironmentProtocol
    
    public init() {}
    
    public func handle(state: State, action: Action, environment: Environment) async -> Action? {
        switch action {
        case .showSnackBar(let type):
            environment.showSnackBar(type)
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
}
