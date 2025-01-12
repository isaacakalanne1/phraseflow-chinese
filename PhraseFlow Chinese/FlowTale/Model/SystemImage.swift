//
//  SystemImage.swift
//  FlowTale
//
//  Created by iakalann on 19/12/2024.
//

import Foundation

enum SystemImage {
    case _repeat,
         speaker,
         pause,
         gear(isFilled: Bool),
         play,
         list(isFilled: Bool),
         ellipsis,
         arrowDown,
         heart,
         starFilled,
         star,
         book(isFilled: Bool),
         bookClosed(isFilled: Bool),
         chartBar(isFilled: Bool)

    var systemName: String {
        switch self {
        case ._repeat:
            "repeat.circle.fill"
        case .speaker:
            "speaker.circle.fill"
        case .pause:
            "pause.circle.fill"
        case .gear(let isFilled):
            "gearshape\(isFilled ? ".fill" : "")"
        case .play:
            "play.circle.fill"
        case .list(let isFilled):
            "list.bullet.rectangle\(isFilled ? ".fill" : "")"
        case .ellipsis:
            "ellipsis.circle"
        case .arrowDown:
            "arrow.down.to.line.circle.fill"
        case .heart:
            "suit.heart"
        case .starFilled:
            "star.fill"
        case .star:
            "star"
        case .book(let isFilled):
            "book\(isFilled ? ".fill" : "")"
        case .bookClosed(let isFilled):
            "book.closed\(isFilled ? ".fill" : "")"
        case .chartBar(let isFilled):
            "chart.bar\(isFilled ? ".fill" : "")"
        }
    }
}
