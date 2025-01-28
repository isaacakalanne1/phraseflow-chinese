//
//  CreateStorySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 22/11/2024.
//

import SwiftUI

struct CreateStorySettingsView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss

    @State var isShowingLanguageSettings = false
    @State var isShowingDifficultySettings = false
    @State var isShowingPromptSettings = false
    @State var isShowingVoiceSettings = false
    @State var isShowingSpeedSettings = false

    var body: some View {

        let currentDifficulty = store.state.settingsState.difficulty
        let currentLanguage = store.state.settingsState.language
        let currentStorySetting = store.state.settingsState.storySetting

        VStack {
            List {
                Section {
                    Button {
                        isShowingLanguageSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Text(currentLanguage.flagEmoji + " " + currentLanguage.displayName)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, color: FlowTaleColor.secondary)
                        }
                    }
                } header: {
                    Text(LocalizedString.language)
                }
                
                Section {
                    Button {
                        isShowingDifficultySettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            DifficultyView(difficulty: currentDifficulty)
                            Text(currentDifficulty.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, color: FlowTaleColor.secondary)
                        }
                    }
                } header: {
                    Text(LocalizedString.difficulty)
                }

                Section {
                    Button {
                        isShowingPromptSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Text(currentStorySetting.emoji + " " + currentStorySetting.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                                .lineLimit(1)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, color: FlowTaleColor.secondary)
                        }
                    }
                } header: {
                    Text(LocalizedString.story)
                }

                Section {
                    Button {
                        isShowingVoiceSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Text(store.state.settingsState.voice.gender.emoji + " " + store.state.settingsState.voice.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                                .lineLimit(1)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, color: FlowTaleColor.secondary)
                        }
                    }
                } header: {
                    Text(LocalizedString.voice)
                }

                Section {
                    Button {
                        isShowingSpeedSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Text(store.state.settingsState.speechSpeed.emoji + " " + store.state.settingsState.speechSpeed.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                                .lineLimit(1)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, color: FlowTaleColor.secondary)
                        }
                    }
                } header: {
                    Text("Speech Speed") // TODO: Localize
                }

            }
            .frame(maxHeight: .infinity)
            .scrollBounceBehavior(.basedOnSize)

            CreateStoryButton()
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .bottom])
        }
        .navigationTitle(LocalizedString.createStory)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
        .navigationDestination(
            isPresented: $isShowingLanguageSettings
        ) {
            LanguageSettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingDifficultySettings
        ) {
            DifficultySettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingPromptSettings
        ) {
            StoryPromptSettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingVoiceSettings
        ) {
            VoiceSettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingSpeedSettings
        ) {
            SpeechSpeedSettingsView()
        }
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first,
              let prompt = store.state.settingsState.customPrompts[safe: index] else { return }
        store.dispatch(.deleteCustomPrompt(prompt))
    }
}

struct CreateStoryButton: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        Button {
            store.dispatch(.playSound(.createStory))
            store.dispatch(.selectTab(.reader, shouldPlaySound: false))
            store.dispatch(.continueStory(story: store.state.createNewStory()))
        } label: {
            HStack(spacing: 5) {
                DifficultyView(difficulty: store.state.settingsState.difficulty, color: FlowTaleColor.primary)
                Text(store.state.settingsState.language.flagEmoji + " " + LocalizedString.newStory)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(FlowTaleColor.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
