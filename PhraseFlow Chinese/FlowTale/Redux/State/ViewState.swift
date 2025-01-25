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

    var isShowingSubscriptionSheet = false
    var subscriptionSheetType: SubscriptionSheetType = .manualOpen
    var isShowingCustomPromptAlert = false
    var isShowingModerationFailedAlert = false

    var isShowingModerationDetails = false

    var isShowingLanguageSettings = false
    var isShowingDifficultySettings = false
    var isShowingPromptSettings = false
    var isShowingVoiceSettings = false
    var isShowingSpeedSettings = false

    var isAutoscrollEnabled = false
    var isDefining = false

    var readerDisplayType: ReaderDisplayType
    var contentTab: ContentTab
    var playButtonDisplayType: PlayButtonDisplayType

    var loadingState: LoadingState

    init(definitionViewId: UUID = UUID(),
         chapterViewId: UUID = UUID(),
         translationViewId: UUID = UUID(),
         storyListViewId: UUID = UUID(),
         isShowingSubscriptionSheet: Bool = false,
         isShowingCustomPromptAlert: Bool = false,
         isAutoscrollEnabled: Bool = false,
         isDefining: Bool = false,
         readerDisplayType: ReaderDisplayType = .initialising,
         contentTab: ContentTab = .reader,
         playButtonDisplayType: PlayButtonDisplayType = .normal,
         loadingState: LoadingState = .complete) {
        self.definitionViewId = definitionViewId
        self.chapterViewId = chapterViewId
        self.translationViewId = translationViewId
        self.storyListViewId = storyListViewId
        self.isShowingSubscriptionSheet = isShowingSubscriptionSheet
        self.isShowingCustomPromptAlert = isShowingCustomPromptAlert
        self.isAutoscrollEnabled = isAutoscrollEnabled
        self.isDefining = isDefining
        self.readerDisplayType = readerDisplayType
        self.contentTab = contentTab
        self.playButtonDisplayType = playButtonDisplayType
        self.loadingState = loadingState
    }
}
