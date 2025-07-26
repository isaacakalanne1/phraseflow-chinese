//
//  StudySubscriber.swift
//  Study
//
//  Created by Isaac Akalanne on 22/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let studySubscriber: OnSubscribe<StudyStore, StudyEnvironmentProtocol> = { store, environment in
    // No reactive subscriptions needed for basic study functionality
}
