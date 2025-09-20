//
//  LoadingStatus.swift
//  FlowTale
//
//  Created by iakalann on 31/12/2024.
//

import Foundation

public enum LoadingStatus: Sendable, Equatable {
    case none, writing, generatingImage, generatingSpeech, generatingDefinitions, complete

    var progressInt: Int {
        switch self {
        case .none:
            -1
        case .writing:
            0
        case .generatingImage:
            1
        case .generatingSpeech:
            2
        case .generatingDefinitions:
            3
        case .complete:
            4
        }
    }
}
