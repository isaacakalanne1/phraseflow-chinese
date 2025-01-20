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

    func image(isFilled: Bool) -> SystemImage {
        switch self {
        case .reader:
                .book(isFilled: isFilled)
        case .storyList:
                .list(isFilled: isFilled)
        case .study:
                .bookClosed(isFilled: isFilled)
        case .progress:
                .chartBar(isFilled: isFilled)
        case .subscribe:
                .heart(isFilled: isFilled)
        case .settings:
                .gear(isFilled: isFilled)
        }
    }
}

enum PlayButtonDisplayType {
    case normal, loading
}
