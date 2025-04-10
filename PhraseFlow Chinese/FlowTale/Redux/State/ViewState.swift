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
    
    // Flag to track if a chapter is currently being written
    var isWritingChapter = false

    var contentTab: ContentTab

    var loadingState: LoadingState
    var shouldShowImageSpinner = false

    var isInitialisingApp: Bool

    init(definitionViewId: UUID = UUID(),
         chapterViewId: UUID = UUID(),
         translationViewId: UUID = UUID(),
         storyListViewId: UUID = UUID(),
         isShowingSubscriptionSheet: Bool = false,
         isShowingCustomPromptAlert: Bool = false,
         isAutoscrollEnabled: Bool = false,
         isDefining: Bool = false,
         isWritingChapter: Bool = false,
         contentTab: ContentTab = .reader,
         loadingState: LoadingState = .complete,
         shouldShowImageSpinner: Bool = false,
         isInitialisingApp: Bool = true) {
        self.definitionViewId = definitionViewId
        self.chapterViewId = chapterViewId
        self.translationViewId = translationViewId
        self.storyListViewId = storyListViewId
        self.isShowingSubscriptionSheet = isShowingSubscriptionSheet
        self.isShowingCustomPromptAlert = isShowingCustomPromptAlert
        self.isAutoscrollEnabled = isAutoscrollEnabled
        self.isDefining = isDefining
        self.isWritingChapter = isWritingChapter
        self.contentTab = contentTab
        self.loadingState = loadingState
        self.shouldShowImageSpinner = shouldShowImageSpinner
        self.isInitialisingApp = isInitialisingApp
    }
}
