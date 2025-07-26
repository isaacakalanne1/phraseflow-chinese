//
//  NavigationSubscriber.swift
//  Navigation
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit

nonisolated(unsafe) let navigationSubscriber: OnSubscribe<NavigationStore, NavigationEnvironmentProtocol> = { store, environment in
    // No reactive subscriptions needed for basic navigation
}