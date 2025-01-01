//
//  LoadingState.swift
//  FlowTale
//
//  Created by iakalann on 31/12/2024.
//

import Foundation

enum LoadingState {
    case complete, writing, translating, generatingSpeech

    var progressInt: Int {
        switch self {
        case .writing:
            0
        case .translating:
            1
        case .generatingSpeech:
            2
        case .complete:
            3
        }
    }
}
