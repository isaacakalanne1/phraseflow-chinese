//
//  CreateStorySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 22/11/2024.
//

import SwiftUI

struct CreateStorySettingsView: View {
    @EnvironmentObject var store: FlowTaleStore

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
                    Text("Language")
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
                    Text("Difficulty")
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
                    Text("Story")
                }

            }
            .frame(maxHeight: .infinity)

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
