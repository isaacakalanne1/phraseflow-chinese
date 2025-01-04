//
//  LoadingState.swift
//  FlowTale
//
//  Created by iakalann on 31/12/2024.
//

import Foundation

enum LoadingState {
    case complete, writing, translating, generatingImage, generatingSpeech

    var progressInt: Int {
        switch self {
        case .writing:
            0
        case .translating:
            1
        case .generatingImage:
            2
        case .generatingSpeech:
            3
        case .complete:
            4
        }
    }
}
