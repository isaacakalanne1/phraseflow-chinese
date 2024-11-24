//
//  SettingsView.swift
//  FastChinese
//
//  Created by iakalann on 11/09/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: FastChineseStore

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
                        Toggle("Definition", isOn: showDefinition)
                            .fontWeight(.light)
                        Toggle("English", isOn: showEnglish)
                            .fontWeight(.light)
                    } header: {
                        Text("Toggle")
                    }
                    Section {
                        ForEach(store.state.storyState.currentStory?.language.voices ?? [], id: \.self) { voice in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.selectVoice(voice))
                                }
                            }) {
                                VStack {
                                    Text(voice.title)
                                        .fontWeight(store.state.settingsState.voice == voice ? .medium : .light)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(voice.gender.title)
                                        .fontWeight(.light)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .foregroundStyle(store.state.settingsState.voice == voice ? Color.accentColor : Color.primary)
                            }
                            .listRowBackground(store.state.settingsState.voice == voice ? Color.gray.opacity(0.3) : Color.white)
                        }
                    } header: {
                        Text("Voice")
                    }
                    Section {
                        ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.updateSpeechSpeed(speed))
                                }
                            }) {
                                Text(speed.title)
                                    .foregroundStyle(store.state.settingsState.speechSpeed == speed ? Color.accentColor : Color.primary)
                                    .fontWeight(store.state.settingsState.speechSpeed == speed ? .medium : .light)
                            }
                            .listRowBackground(store.state.settingsState.speechSpeed == speed ? Color.gray.opacity(0.3) : Color.white)
                        }
                    } header: {
                        Text("Speed")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
