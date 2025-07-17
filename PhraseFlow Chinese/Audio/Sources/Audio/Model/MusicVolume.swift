//
//  MusicVolume.swift
//  FlowTale
//
//  Created by iakalann on 06/04/2025.
//

enum MusicVolume {
    case normal, quiet

    var float: Float {
        switch self {
        case .normal:
            0.5
        case .quiet:
            0.15
        }
    }
}
