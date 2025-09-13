//
//  FlowTaleEnvironment.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import Foundation
import Navigation

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
