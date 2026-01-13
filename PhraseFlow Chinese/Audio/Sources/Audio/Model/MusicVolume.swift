//
//  MusicVolume.swift
//  FlowTale
//
//  Created by iakalann on 06/04/2025.
//

public enum MusicVolume: Sendable {
    case normal, quiet

    var float: Float {
        switch self {
        case .normal:
            0.1
        case .quiet:
            0.02
        }
    }
}
