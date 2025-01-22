//
//  ReaderDisplayType.swift
//  FlowTale
//
//  Created by iakalann on 19/10/2024.
//

import Foundation

enum ReaderDisplayType {
    case normal, loading, initialising
}

enum ContentTab: CaseIterable, Equatable, Identifiable {
    var id: UUID {
        UUID()
    }

    case reader, storyList, study, progress, subscribe, settings

    func image(isSelected: Bool) -> SystemImage {
        switch self {
        case .reader:
                .book(isSelected: isSelected)
        case .storyList:
                .list(isSelected: isSelected)
        case .study:
                .pencil(isSelected: isSelected)
        case .progress:
                .chartLine(isSelected: isSelected)
        case .subscribe:
                .heart(isSelected: isSelected)
        case .settings:
                .gear(isSelected: isSelected)
        }
    }
}

enum PlayButtonDisplayType {
    case normal, loading
}
