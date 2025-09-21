//
//  LoadingStatus.swift
//  FlowTale
//
//  Created by iakalann on 31/12/2024.
//

import Foundation

public enum LoadingStatus: Sendable, Equatable {
    case none, writing, formattingSentences, generatingImage, generatingSpeech, generatingDefinitions, complete

    var progressInt: Int {
        switch self {
        case .none:
            -1
        case .writing:
            0
        case .formattingSentences:
            1
        case .generatingImage:
            2
        case .generatingSpeech:
            3
        case .generatingDefinitions:
            4
        case .complete:
            5
        }
    }
}
