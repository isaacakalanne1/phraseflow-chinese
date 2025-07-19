//
//  LoadingSubscriber.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let loadingSubscriber: OnSubscribe<LoadingStore, LoadingEnvironmentProtocol> = { store, environment in
    // No reactive subscriptions needed for basic navigation
}
