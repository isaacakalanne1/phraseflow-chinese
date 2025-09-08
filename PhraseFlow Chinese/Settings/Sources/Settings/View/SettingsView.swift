//
//  SettingsView.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import SwiftUI
import FTColor
import Localization

struct SettingsView: View {
    @EnvironmentObject var store: SettingsStore

    var body: some View {
        let showDefinition: Binding<Bool> = .init {
            store.state.isShowingDefinition
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            store.dispatch(.updateShowDefinition(newValue))
        }

        let showEnglish: Binding<Bool> = .init {
            store.state.isShowingEnglish
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            store.dispatch(.updateShowEnglish(newValue))
        }

        let playMusic: Binding<Bool> = .init {
            store.state.isPlayingMusic
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            if newValue {
                store.dispatch(.playMusic(.whispersOfTheForest))
            } else {
                store.dispatch(.stopMusic)
            }
        }

        let shouldPlayButtonSounds: Binding<Bool> = .init {
            store.state.shouldPlaySound
        } set: { newValue in
            store.dispatch(.updateShouldPlaySound(newValue))
            if newValue {
                store.dispatch(.playSound(.togglePress))
            }
        }

        let selectedLanguage: Binding<Language> = .init {
            store.state.language
        } set: { newValue in
            store.dispatch(.updateLanguage(newValue))
        }
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        NavigationLink(destination: LanguageSettingsView(selectedLanguage: selectedLanguage,
                                                                         isEnabled: !store.state.viewState.isWritingChapter)) {
                            HStack {
                                Text(LocalizedString.language)
                                    .fontWeight(.light)
                                Spacer()
                                Text(store.state.language.displayName)
                                    .foregroundColor(FTColor.secondary)
                                    .fontWeight(.light)
                            }
                        }
                        
                        NavigationLink(destination: VoiceSettingsView()) {
                            HStack {
                                Text(LocalizedString.voice)
                                    .fontWeight(.light)
                                Spacer()
                                Text(store.state.voice.title)
                                    .foregroundColor(FTColor.secondary)
                                    .fontWeight(.light)
                            }
                        }
                        
                        NavigationLink(destination: DifficultySettingsView()) {
                            HStack {
                                Text(LocalizedString.difficulty)
                                    .fontWeight(.light)
                                Spacer()
                                Text(store.state.difficulty.title)
                                    .foregroundColor(FTColor.secondary)
                                    .fontWeight(.light)
                            }
                        }
                        
                        NavigationLink(destination: StoryPromptSettingsView()) {
                            HStack {
                                Text(LocalizedString.storySettings)
                                    .fontWeight(.light)
                                Spacer()
                                Text(store.state.storySetting.title)
                                    .foregroundColor(FTColor.secondary)
                                    .fontWeight(.light)
                            }
                        }
                    }
                    
                    Section {
                        Toggle(LocalizedString.definitionToggle, isOn: showDefinition)
                            .fontWeight(.light)
                        Toggle(LocalizedString.translation, isOn: showEnglish)
                            .fontWeight(.light)
                    } header: {
                        Text(LocalizedString.settingsAppearance)
                    }
                    Section {
                        Toggle(LocalizedString.music, isOn: playMusic)
                            .fontWeight(.light)
                        Toggle(LocalizedString.settingsSounds, isOn: shouldPlayButtonSounds)
                            .fontWeight(.light)
                    } header: {
                        Text(LocalizedString.settingsSoundHeader)
                    }
                }
            }
            .background(FTColor.background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
}
