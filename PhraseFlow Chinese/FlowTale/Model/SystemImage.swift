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
         gear(isSelected: Bool),
         pencil(isSelected: Bool),
         play,
         stop,
         list(isSelected: Bool),
         ellipsis,
         arrowDown,
         heart(isSelected: Bool),
         starFilled,
         star,
         book(isSelected: Bool),
         chartLine(isSelected: Bool),
         plus(isSelected: Bool),
         chevronRight,
         translate(isSelected: Bool),
         xmark

    var systemName: String {
        switch self {
        case ._repeat:
            "repeat.circle.fill"
        case .speaker:
            "speaker.circle.fill"
        case .pause:
            "pause.fill"
        case let .gear(isSelected):
            "gearshape\(isSelected ? ".2.fill" : "")"
        case let .pencil(isSelected):
            isSelected ? "pencil.and.outline" : "square.and.pencil"
        case .play:
            "play.fill"
        case .stop:
            "stop.circle.fill"
        case let .list(isSelected):
            isSelected ? "doc.text.magnifyingglass" : "list.bullet.rectangle.portrait"
        case .ellipsis:
            "ellipsis.circle"
        case .arrowDown:
            "arrow.down.to.line.circle.fill"
        case let .heart(isSelected):
            "suit.heart\(isSelected ? ".fill" : "")"
        case .starFilled:
            "star.fill"
        case .star:
            "star"
        case let .book(isSelected):
            "book\(isSelected ? ".fill" : ".closed")"
        case let .chartLine(isSelected):
            isSelected ? "chart.line.uptrend.xyaxis" : "chart.xyaxis.line"
        case let .plus(isSelected):
            isSelected ? "plus.message.fill" : "plus.circle"
        case .chevronRight:
            "chevron.right.square.fill"
        case let .translate(isSelected):
            isSelected ? "character.bubble.fill" : "character.bubble"
        case .xmark:
            "xmark.circle.fill"
        }
    }
}
