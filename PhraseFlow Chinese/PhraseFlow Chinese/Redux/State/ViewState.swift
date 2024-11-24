//
//  ViewState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct ViewState {
    var definitionViewId: UUID
    var chapterViewId: UUID
    var translationViewId: UUID
    var storyListViewId: UUID

    var isShowingCreateStoryScreen = false
    var isShowingSettingsScreen = false
    var isShowingStoryListView = false

    var readerDisplayType: ReaderDisplayType
    var playButtonDisplayType: PlayButtonDisplayType

    init(definitionViewId: UUID = UUID(),
         chapterViewId: UUID = UUID(),
         translationViewId: UUID = UUID(),
         storyListViewId: UUID = UUID(),
         isShowingCreateStoryScreen: Bool = false,
         isShowingSettingsScreen: Bool = false,
         isShowingStoryListView: Bool = false,
         readerDisplayType: ReaderDisplayType = .fetching,
         playButtonDisplayType: PlayButtonDisplayType = .normal) {
        self.definitionViewId = definitionViewId
        self.chapterViewId = chapterViewId
        self.translationViewId = translationViewId
        self.storyListViewId = storyListViewId
        self.isShowingCreateStoryScreen = isShowingCreateStoryScreen
        self.isShowingSettingsScreen = isShowingSettingsScreen
        self.isShowingStoryListView = isShowingStoryListView
        self.readerDisplayType = readerDisplayType
        self.playButtonDisplayType = playButtonDisplayType
    }
}
