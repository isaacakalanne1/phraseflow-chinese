//
//  SettingsView.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.colorScheme) var colorScheme

    var body: some View {

        let showDefinition: Binding<Bool> = .init {
            store.state.settingsState.isShowingDefinition
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            store.dispatch(.updateShowDefinition(newValue))
        }

        let showEnglish: Binding<Bool> = .init {
            store.state.settingsState.isShowingEnglish
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            store.dispatch(.updateShowEnglish(newValue))
        }

        let playMusic: Binding<Bool> = .init {
            store.state.settingsState.isPlayingMusic
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            if newValue {
                store.dispatch(.playMusic(.whispersOfAnOpenBook))
            } else {
                store.dispatch(.stopMusic)
            }
        }

        let isDarkMode: Binding<Bool> = .init {
            (store.state.settingsState.appColorScheme?.colorScheme ?? colorScheme) == .dark
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            store.dispatch(.updateColorScheme(newValue ? .dark : .light))
        }

        let shouldPlayButtonSounds: Binding<Bool> = .init {
            store.state.settingsState.shouldPlaySound
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
                    Toggle("Dark Mode", isOn: isDarkMode) // TODO: Localize
                        .fontWeight(.light)
                } header: {
                    Text("Appearance") // TODO: Localize
                }
                Section {
                    Toggle(LocalizedString.music, isOn: playMusic)
                        .fontWeight(.light)
                    Toggle("Sounds", isOn: shouldPlayButtonSounds) // TODO: Localize
                        .fontWeight(.light)
                } header: {
                    Text("Sound") // TODO: Localize
                }
            }
        }
        .navigationTitle(LocalizedString.settings)
        .navigationBarTitleDisplayMode(.inline)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
}
