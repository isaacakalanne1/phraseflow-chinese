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

    var body: some View {

        let currentDifficulty = store.state.settingsState.difficulty
        let currentLanguage = store.state.settingsState.language
        let currentStorySetting = store.state.settingsState.storySetting

        VStack {
            List {
                Section {
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        Text(currentLanguage.flagEmoji + " " + currentLanguage.displayName)
                            .fontWeight(.light)
                            .foregroundStyle(FlowTaleColor.primary)
                    }
                } header: {
                    Text(LocalizedString.language)
                }
                
                Section {
                    NavigationLink {
                        DifficultySettingsView()
                    } label: {
                        HStack {
                            DifficultyView(difficulty: currentDifficulty)
                            Text(currentDifficulty.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                        }
                    }
                } header: {
                    Text(LocalizedString.difficulty)
                }

                Section {
                    NavigationLink {
                        StoryPromptSettingsView()
                    } label: {
                        Text(currentStorySetting.emoji + " " + currentStorySetting.title)
                            .fontWeight(.light)
                            .foregroundStyle(FlowTaleColor.primary)
                            .lineLimit(1)
                    }
                } header: {
                    Text(LocalizedString.story)
                }

                Section {
                    NavigationLink {
                        VoiceSettingsView()
                    } label: {
                        Text(store.state.settingsState.voice.gender.emoji + " " + store.state.settingsState.voice.title)
                            .fontWeight(.light)
                            .foregroundStyle(FlowTaleColor.primary)
                            .lineLimit(1)
                    }
                } header: {
                    Text(LocalizedString.voice)
                }

                Section {
                    NavigationLink {
                        SpeechSpeedSettingsView()
                    } label: {
                        Text(store.state.settingsState.speechSpeed.emoji + " " + store.state.settingsState.speechSpeed.title)
                            .fontWeight(.light)
                            .foregroundStyle(FlowTaleColor.primary)
                            .lineLimit(1)
                    }
                } header: {
                    Text("Speech Speed") // TODO: Localize
                }

            }
            .frame(maxHeight: .infinity)

            PrimaryButton(title: "Done") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle(store.state.storyState.currentStory == nil ? LocalizedString.createStory : LocalizedString.storySettings)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
        .onAppear {
            store.dispatch(.playSound(.openStorySettings))
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
            .padding()
            .background(FlowTaleColor.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
