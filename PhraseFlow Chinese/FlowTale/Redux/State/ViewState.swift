//
//  ViewState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct ViewState {
    var definitionViewId: UUID
    var chapterViewId: UUID
    var translationViewId: UUID
    var storyListViewId: UUID

    var isShowingSettingsScreen = false
    var isShowingStoryListView = false
    var isShowingStudyView = false
    var isShowingDefinitionsChartView = false
    var isShowingSubscriptionSheet = false

    var isAutoscrollEnabled = false

    var readerDisplayType: ReaderDisplayType
    var playButtonDisplayType: PlayButtonDisplayType

    init(definitionViewId: UUID = UUID(),
         chapterViewId: UUID = UUID(),
         translationViewId: UUID = UUID(),
         storyListViewId: UUID = UUID(),
         isShowingSettingsScreen: Bool = false,
         isShowingStoryListView: Bool = false,
         isShowingSubscriptionSheet: Bool = false,
         readerDisplayType: ReaderDisplayType = .normal,
         playButtonDisplayType: PlayButtonDisplayType = .normal) {
        self.definitionViewId = definitionViewId
        self.chapterViewId = chapterViewId
        self.translationViewId = translationViewId
        self.storyListViewId = storyListViewId
        self.isShowingSettingsScreen = isShowingSettingsScreen
        self.isShowingStoryListView = isShowingStoryListView
        self.isShowingSubscriptionSheet = isShowingSubscriptionSheet
        self.readerDisplayType = readerDisplayType
        self.playButtonDisplayType = playButtonDisplayType
    }
}
