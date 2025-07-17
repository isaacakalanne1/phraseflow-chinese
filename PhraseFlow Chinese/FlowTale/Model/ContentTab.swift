//
//  ContentTab.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import Foundation

enum ContentTab: CaseIterable, Equatable, Identifiable {
    var id = UUID()

    case reader, storyList, progress, translate, subscribe, settings

    var title: String {
        switch self {
        case .reader:
            ""
        case .storyList:
            LocalizedString.chooseStory
        case .progress:
            LocalizedString.progress
        case .translate:
            LocalizedString.translate
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
        case .translate:
            .translate(isSelected: isSelected)
        case .subscribe:
            .heart(isSelected: isSelected)
        case .settings:
            .gear(isSelected: isSelected)
        }
    }
}
