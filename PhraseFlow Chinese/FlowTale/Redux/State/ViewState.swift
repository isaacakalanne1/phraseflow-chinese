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
    var isShowingCustomPromptAlert = false
    var isShowingModerationFailedAlert = false

    var isShowingModerationDetails = false

    var isShowingFreeLimitExplanation = false
    var isShowingDailyLimitExplanation = false

    var isAutoscrollEnabled = false
    var isDefining = false

    var contentTab: ContentTab

    init(definitionViewId: UUID = UUID(),
         chapterViewId: UUID = UUID(),
         translationViewId: UUID = UUID(),
         storyListViewId: UUID = UUID(),
         isShowingSubscriptionSheet: Bool = false,
         isShowingCustomPromptAlert: Bool = false,
         isAutoscrollEnabled: Bool = false,
         isDefining: Bool = false,
         readerDisplayType: ReaderDisplayType = .initialising,
         contentTab: ContentTab = .reader) {
        self.definitionViewId = definitionViewId
        self.chapterViewId = chapterViewId
        self.translationViewId = translationViewId
        self.storyListViewId = storyListViewId
        self.isShowingSubscriptionSheet = isShowingSubscriptionSheet
        self.isShowingCustomPromptAlert = isShowingCustomPromptAlert
        self.isAutoscrollEnabled = isAutoscrollEnabled
        self.isDefining = isDefining
        self.contentTab = contentTab
    }
}
