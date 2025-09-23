//
//  AudioMiddleware.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import Foundation
import ReduxKit
import Moderation

@MainActor
let audioMiddleware: Middleware<AudioState, AudioAction,  AudioEnvironmentProtocol> = { state, action, environment in
    return nil
}
