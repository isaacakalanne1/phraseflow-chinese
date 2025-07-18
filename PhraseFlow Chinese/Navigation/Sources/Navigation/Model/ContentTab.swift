//
//  ContentTab.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

import AppleIcon
import Foundation
import Localization
import SwiftUI

enum ContentTab: CaseIterable, Equatable, Identifiable {
    var id: UUID {
        UUID()
    }

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

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .reader:
            NavigationStack {
                ReaderView(chapter: chapter)
                    .navigationDestination(
                        isPresented: isShowingDailyLimitExplanationScreen
                    ) {
                        DailyLimitExplanationView()
                    }
                    .navigationDestination(
                        isPresented: isShowingFreeLimitExplanationScreen
                    ) {
                        FreeLimitExplanationView()
                    }
            }

        case .storyList:
            NavigationStack {
                StoryListView()
                    .navigationDestination(
                        isPresented: isShowingDailyLimitExplanationScreen
                    ) {
                        DailyLimitExplanationView()
                    }
            }

        case .progress:
            NavigationStack {
                DefinitionsProgressSheetView()
            }

        case .translate:
            NavigationStack {
                TranslationView()
            }

        case .subscribe:
            NavigationStack {
                SubscriptionView()
                    .navigationDestination(
                        isPresented: isShowingFreeLimitExplanationScreen
                    ) {
                        FreeLimitExplanationView()
                    }
            }

        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}
