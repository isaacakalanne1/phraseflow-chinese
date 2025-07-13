//
//  SettingsView.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        let showDefinition: Binding<Bool> = .init {
            store.state.settingsState.isShowingDefinition
        } set: { newValue in
            store.dispatch(.audioAction(.playSound(.togglePress)))
            store.dispatch(.appSettingsAction(.updateShowDefinition(newValue)))
        }

        let showEnglish: Binding<Bool> = .init {
            store.state.settingsState.isShowingEnglish
        } set: { newValue in
            store.dispatch(.audioAction(.playSound(.togglePress)))
            store.dispatch(.appSettingsAction(.updateShowEnglish(newValue)))
        }

        let playMusic: Binding<Bool> = .init {
            store.state.settingsState.isPlayingMusic
        } set: { newValue in
            store.dispatch(.audioAction(.playSound(.togglePress)))
            if newValue {
                store.dispatch(.audioAction(.playMusic(.whispersOfTheForest)))
            } else {
                store.dispatch(.audioAction(.stopMusic))
            }
        }

        let shouldPlayButtonSounds: Binding<Bool> = .init {
            store.state.settingsState.shouldPlaySound
        } set: { newValue in
            store.dispatch(.appSettingsAction(.updateShouldPlaySound(newValue)))
            if newValue {
                store.dispatch(.audioAction(.playSound(.togglePress)))
            }
        }

        VStack(spacing: 0) {
            List {
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
        .navigationTitle(ContentTab.settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(.ftBackground)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
}
