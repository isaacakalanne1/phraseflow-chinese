//
//  SystemImage.swift
//  FlowTale
//
//  Created by iakalann on 19/12/2024.
//

import Foundation

enum SystemImage {
    case _repeat, speaker, pause, gear, play, list, ellipsis, arrowDown, heart

    var systemName: String {
        switch self {
        case ._repeat:
            "repeat.circle.fill"
        case .speaker:
            "speaker.circle.fill"
        case .pause:
            "pause.circle.fill"
        case .gear:
            "gearshape.fill"
        case .play:
            "play.circle"
        case .list:
            "list.bullet"
        case .ellipsis:
            "ellipsis.circle"
        case .arrowDown:
            "arrow.down.to.line.circle"
        case .heart:
            "suit.heart.fill"
        }
    }
}
