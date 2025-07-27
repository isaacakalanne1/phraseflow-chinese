//
//  FlowTaleState.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import Audio
import Story
import Settings
import Study
import Translation
import Subscription
import SnackBar
import UserLimit
import Moderation
import Navigation
import Loading

struct FlowTaleState {
    var audioState: AudioState
    var storyState: StoryState
    var settingsState: SettingsState
    var studyState: StudyState
    var translationState: TranslationState
    var subscriptionState: SubscriptionState
    var snackBarState: SnackBarState
    var userLimitState: UserLimitState
    var moderationState: ModerationState
    var navigationState: NavigationState
    var loadingState: LoadingState
    var viewState: ViewState
    
    init(locale: Locale = .current) {
        self.settingsState = SettingsState()
        self.audioState = AudioState(speechSpeed: self.settingsState.speechSpeed)
        self.storyState = StoryState()
        self.studyState = StudyState()
        self.translationState = TranslationState()
        self.subscriptionState = SubscriptionState()
        self.snackBarState = SnackBarState()
        self.userLimitState = UserLimitState()
        self.moderationState = ModerationState()
        self.navigationState = NavigationState()
        self.loadingState = LoadingState()
        self.viewState = ViewState()
        
        // Set device language based on locale
        if let language = Language.from(locale: locale) {
            self.settingsState.deviceLanguage = language
        }
    }
    
    var deviceLanguage: Language? {
        settingsState.deviceLanguage
    }
}

struct ViewState {
    var isInitialisingApp: Bool = true
    var contentTab: ContentTab = .reader
    var isShowingSubscriptionSheet: Bool = false
    var isShowingDailyLimitExplanation: Bool = false
    var isShowingFreeLimitExplanation: Bool = false
    var loadingState: LoadingState = LoadingState()
    var isDefining: Bool = false
    var isWritingChapter: Bool = false
    var definitionViewId: UUID = UUID()
    var isShowingCustomPromptAlert: Bool = false
}

enum ContentTab {
    case reader
    case storyList
    case progress
    case translate
    case subscribe
    case settings
}