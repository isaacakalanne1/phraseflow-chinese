//
//  AudioStore.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import Foundation
import ReduxKit

typealias AudioStore = Store<AudioState, AudioAction, AudioEnvironmentProtocol>
