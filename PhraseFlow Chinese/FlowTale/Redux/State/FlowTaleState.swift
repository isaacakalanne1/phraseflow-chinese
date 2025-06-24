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
    var audioState = AudioState()
    var studyState = StudyState()
    var translationState = TranslationState()
    var snackBarState = SnackBarState()
    var definitionState = DefinitionState()
    var viewState = ViewState()
    var subscriptionState = SubscriptionState()
    var appAudioState = AppAudioState()
    var musicAudioState = MusicAudioState()
    var locale: Locale
    var moderationResponse: ModerationResponse?

    var deviceLanguage: Language {
        Language.allCases.first(where: { $0.identifier == locale.language.languageCode?.identifier }) ?? .english
    }

    init(settingsState: SettingsState = SettingsState(),
         storyState: StoryState = StoryState(),
         audioState: AudioState = AudioState(),
         definitionState: DefinitionState = DefinitionState(),
         viewState: ViewState = ViewState(),
         subscriptionState: SubscriptionState = SubscriptionState(),
         locale: Locale = Locale.current) {
        self.settingsState = settingsState
        self.storyState = storyState
        self.audioState = audioState
        self.definitionState = definitionState
        self.viewState = viewState
        self.subscriptionState = subscriptionState
        self.locale = locale
    }
}
