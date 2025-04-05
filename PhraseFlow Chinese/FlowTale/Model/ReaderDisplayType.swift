//
//  ReaderDisplayType.swift
//  FlowTale
//
//  Created by iakalann on 19/10/2024.
//

import Foundation

enum ReaderDisplayType {
    case normal, initialising
}

enum ContentTab: CaseIterable, Equatable, Identifiable {
    var id: UUID {
        UUID()
    }

    case reader, storyList, progress, subscribe, settings

    var title: String {
        switch self {
        case .reader:
            ""
        case .storyList:
            LocalizedString.chooseStory
        case .progress:
            LocalizedString.progress
        case .subscribe:
            LocalizedString.subscribe
        case .settings:
            LocalizedString.settings
        }
    }
    
    func image(isSelected: Bool) -> SystemImage {
        switch self {
        case .reader:
                .book(isSelected: isSelected)
        case .storyList:
                .list(isSelected: isSelected)
        case .progress:
                .chartLine(isSelected: isSelected)
        case .subscribe:
                .heart(isSelected: isSelected)
        case .settings:
                .gear(isSelected: isSelected)
        }
    }
}
