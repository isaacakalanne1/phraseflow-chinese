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

        let showPinyin: Binding<Bool> = .init {
            store.state.settingsState.isShowingPinyin
        } set: { newValue in
            store.dispatch(.updateShowPinyin(newValue))
        }

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
            VStack(spacing: 20) {

                Spacer()

                Text("Toggle")
                    .fontWeight(.light)
                    .greyBackground()

//                Toggle("Pinyin", isOn: showPinyin)
//                    .fontWeight(.light)
                Toggle("Definition", isOn: showDefinition)
                    .fontWeight(.light)
                Toggle("English", isOn: showEnglish)
                    .fontWeight(.light)

                voicesView
                speedView
                difficultyView
            }
            .padding(.horizontal)
        }
        .navigationTitle("Settings")
    }

    @ViewBuilder
    var voicesView: some View {
        Text("Voice")
            .fontWeight(.light)
            .greyBackground()
        ScrollView(.horizontal) {
            HStack {
                ForEach(Voice.allCases, id: \.self) { voice in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            store.dispatch(.selectVoice(voice))
                        }
                    }) {
                        VStack {
                            Text(voice.title)
                                .fontWeight(.medium)
                            Text(voice.gender.title)
                                .fontWeight(.light)
                        }
                        .foregroundColor(store.state.settingsState.voice == voice ? .white : .primary)
                        .padding()
                        .background(store.state.settingsState.voice == voice ? Color.accentColor : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var speedView:  some View {
        Text("Speech")
            .fontWeight(.light)
            .greyBackground()

        HStack {
            ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                Button(action: {
                    withAnimation(.easeInOut) {
                        store.dispatch(.updateSpeechSpeed(speed))
                    }
                }) {
                    Text(speed.title)
                        .font(.body)
                        .foregroundColor(store.state.settingsState.speechSpeed == speed ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(store.state.settingsState.speechSpeed == speed ? Color.accentColor : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
            }
        }
    }

    @ViewBuilder
    var difficultyView:  some View {
        Text("Difficulty")
            .fontWeight(.light)
            .greyBackground()

        ScrollView(.horizontal) {
            HStack {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            store.dispatch(.updateDifficulty(difficulty))
                        }
                    }) {
                        Text(difficulty.title)
                            .font(.body)
                            .foregroundColor(store.state.settingsState.difficulty == difficulty ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(store.state.settingsState.difficulty == difficulty ? Color.accentColor : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }

}
