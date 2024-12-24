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
            store.dispatch(.updateShowDefinition(newValue))
        }

        let showEnglish: Binding<Bool> = .init {
            store.state.settingsState.isShowingEnglish
        } set: { newValue in
            store.dispatch(.updateShowEnglish(newValue))
        }


        NavigationView {
            VStack(spacing: 0) {
                List {
                    Section {
                        Toggle(LocalizedString.definitionToggle, isOn: showDefinition)
                            .fontWeight(.light)
                        Toggle(LocalizedString.englishToggle, isOn: showEnglish)
                            .fontWeight(.light)
                    } header: {
                        Text(LocalizedString.toggle)
                    }
                    Section {
                        ForEach(store.state.storyState.currentStory?.language.voices.sorted(by: { $0.gender.title < $1.gender.title }) ?? [], id: \.self) { voice in
                            let isSelectedVoice = store.state.settingsState.voice == voice

                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.selectVoice(voice))
                                }
                            }) {
                                VStack {
                                    Text(voice.title)
                                        .fontWeight(isSelectedVoice ? .medium : .light)
                                    Text(voice.gender.title)
                                        .fontWeight(.light)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(isSelectedVoice ? Color.accentColor : Color.primary)
                            }
                            .listRowBackground(isSelectedVoice ? Color.gray.opacity(0.3) : Color.white)
                        }
                    } header: {
                        Text(LocalizedString.voice)
                    }
                    Section {
                        ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                            let isSelectedSpeed = store.state.settingsState.speechSpeed == speed
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.updateSpeechSpeed(speed))
                                }
                            }) {
                                Text(speed.title)
                                    .foregroundStyle(isSelectedSpeed ? Color.accentColor : Color.primary)
                                    .fontWeight(isSelectedSpeed ? .medium : .light)
                            }
                            .listRowBackground(isSelectedSpeed ? Color.gray.opacity(0.3) : Color.white)
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
