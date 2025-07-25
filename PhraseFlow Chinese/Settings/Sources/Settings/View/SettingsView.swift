//
//  SettingsView.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import SwiftUI
import FTColor

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
        .background(FTColor.background)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
}
