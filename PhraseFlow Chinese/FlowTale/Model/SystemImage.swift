//
//  SystemImage.swift
//  FlowTale
//
//  Created by iakalann on 19/12/2024.
//

import Foundation

enum SystemImage {
    case _repeat, speaker, pause, gear, play, list, ellipsis, arrowDown, heart, starFilled, star, book

    var systemName: String {
        switch self {
        case ._repeat:
            "repeat.circle.fill"
        case .speaker:
            "speaker.circle.fill"
        case .pause:
            "pause.fill"
        case .gear:
            "gearshape.fill"
        case .play:
            "play.fill"
        case .list:
            "list.bullet"
        case .ellipsis:
            "ellipsis.circle"
        case .arrowDown:
            "arrow.down.to.line.circle"
        case .heart:
            "suit.heart.fill"
        case .starFilled:
            "star.fill"
        case .star:
            "star"
        case .book:
            "book.fill"
        }
    }
}
