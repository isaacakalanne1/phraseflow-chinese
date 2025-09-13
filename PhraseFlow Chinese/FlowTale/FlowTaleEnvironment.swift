//
//  FlowTaleEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import Foundation
import Audio
import Story
import Settings
import Study
import Translation
import Subscription
import SnackBar
import UserLimit
import Moderation
import Navigation
import Loading

protocol FlowTaleEnvironmentProtocol {
    var navigationEnvironment: NavigationEnvironmentProtocol { get }
}

struct FlowTaleEnvironment: FlowTaleEnvironmentProtocol {
    let navigationEnvironment: NavigationEnvironmentProtocol
}

// TODO: Implement proper mock environment according to refactoring guide
// For now, this is a placeholder to get the project compiling
extension FlowTaleEnvironment {
    static var mock: FlowTaleEnvironment {
        fatalError("Mock FlowTaleEnvironment not implemented - refactoring needed")
    }
}
