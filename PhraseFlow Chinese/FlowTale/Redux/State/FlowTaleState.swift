//
//  FlowTaleState.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import SwiftUI

struct FlowTaleState {
    var settingsState = SettingsState()
    var storyState = StoryState()
    var studyState = StudyState()
    var snackBarState = SnackBarState()
    var definitionState = DefinitionState()
    var viewState = ViewState()
    var subscriptionState = SubscriptionState()
    var appAudioState = AppAudioState()
    var musicAudioState = MusicAudioState()
    var locale: Locale {
        Locale.current
    }
    var moderationResponse: ModerationResponse?

    var deviceLanguage: Language? {
        Language.allCases.first(where: { $0.identifier == locale.language.languageCode?.identifier })
    }

    init(settingsState: SettingsState = SettingsState(),
         storyState: StoryState = StoryState(),
         definitionState: DefinitionState = DefinitionState(),
         viewState: ViewState = ViewState(),
         subscriptionState: SubscriptionState = SubscriptionState()) {
        self.settingsState = settingsState
        self.storyState = storyState
        self.definitionState = definitionState
        self.viewState = viewState
        self.subscriptionState = subscriptionState
    }
}
