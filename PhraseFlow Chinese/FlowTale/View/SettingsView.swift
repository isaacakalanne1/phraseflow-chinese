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

        NavigationView {
            VStack(spacing: 0) {
                List {
                    Section {
                        Toggle(LocalizedString.definitionToggle, isOn: showDefinition)
                            .fontWeight(.light)
                        Toggle(LocalizedString.englishToggle, isOn: showEnglish)
                            .fontWeight(.light)
                        Toggle("Music", isOn: playMusic)
                            .fontWeight(.light)
                    } header: {
                        Text(LocalizedString.toggle)
                    }
                    Section {
                        let sortedVoices = store.state.storyState.currentStory?.language.voices
                            .sorted(by: { $0.gender.title < $1.gender.title })
                        ForEach(sortedVoices ?? [],
                                id: \.self) { voice in
                            let isSelectedVoice = store.state.settingsState.voice == voice

                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.changeSettings))
                                    store.dispatch(.selectVoice(voice))
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(voice.title)
                                        .fontWeight(isSelectedVoice ? .medium : .light)
                                    Text(voice.gender.title)
                                        .fontWeight(.light)
                                }
                                .foregroundStyle(isSelectedVoice ? FlowTaleColor.accent : FlowTaleColor.primary)
                            }
                            .listRowBackground(isSelectedVoice ? FlowTaleColor.secondary : FlowTaleColor.background)
                        }
                    } header: {
                        Text(LocalizedString.voice)
                    }
                    Section {
                        ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                            let isSelectedSpeed = store.state.settingsState.speechSpeed == speed
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.changeSettings))
                                    store.dispatch(.pauseAudio)
                                    store.dispatch(.updateSpeechSpeed(speed))
                                }
                            }) {
                                Text(speed.title)
                                    .foregroundStyle(isSelectedSpeed ? FlowTaleColor.accent : FlowTaleColor.primary)
                                    .fontWeight(isSelectedSpeed ? .medium : .light)
                            }
                            .listRowBackground(isSelectedSpeed ? FlowTaleColor.secondary : FlowTaleColor.background)
                        }
                    } header: {
                        Text(LocalizedString.speed)
                    }
                }
            }
            .navigationTitle(LocalizedString.settings)
        }
    }
}
