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
         list(isSelected: Bool),
         ellipsis,
         arrowDown,
         heart(isSelected: Bool),
         starFilled,
         star,
         book(isSelected: Bool),
         chartLine(isSelected: Bool),
         plus(isSelected: Bool),
         chevronRight

    var systemName: String {
        switch self {
        case ._repeat:
            "repeat.circle.fill"
        case .speaker:
            "speaker.circle.fill"
        case .pause:
            "pause.circle.fill"
        case .gear(let isSelected):
            "gearshape\(isSelected ? ".2.fill" : "")"
        case .pencil(let isSelected):
            isSelected ? "pencil.and.outline" : "square.and.pencil"
        case .play:
            "play.circle.fill"
        case .list(let isSelected):
            isSelected ? "doc.text.magnifyingglass" : "list.bullet.rectangle.portrait"
        case .ellipsis:
            "ellipsis.circle"
        case .arrowDown:
            "arrow.down.to.line.circle.fill"
        case .heart(let isSelected):
            "suit.heart\(isSelected ? ".fill" : "")"
        case .starFilled:
            "star.fill"
        case .star:
            "star"
        case .book(let isSelected):
            "book\(isSelected ? ".fill" : ".closed")"
        case .chartLine(let isSelected):
            isSelected ? "chart.line.uptrend.xyaxis" : "chart.xyaxis.line"
        case .plus(let isSelected):
            isSelected ? "plus.message.fill" : "plus.circle"
        case .chevronRight:
            "chevron.right.square.fill"
        }
    }
}
