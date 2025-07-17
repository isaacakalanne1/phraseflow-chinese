//
//  LoadingState.swift
//  FlowTale
//
//  Created by iakalann on 31/12/2024.
//

import Foundation

public enum LoadingState {
    case complete, writing, generatingImage, generatingSpeech

    var progressInt: Int {
        switch self {
        case .writing:
            0
        case .generatingImage:
            1
        case .generatingSpeech:
            2
        case .complete:
            3
        }
    }
}
