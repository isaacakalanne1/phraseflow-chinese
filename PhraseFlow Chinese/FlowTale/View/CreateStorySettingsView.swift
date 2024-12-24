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
        NavigationView {
            VStack {
                List {
                    Section {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            Button {
                                store.dispatch(.updateDifficulty(difficulty))
                            } label: {
                                Text(difficulty.emoji + " " + difficulty.title)
                                    .fontWeight(store.state.settingsState.difficulty == difficulty ? .medium : .light)
                                    .foregroundStyle(store.state.settingsState.difficulty == difficulty ? Color.accentColor : Color.primary)
                            }
                            .listRowBackground(store.state.settingsState.difficulty == difficulty ? Color.gray.opacity(0.3) : Color.white)
                        }
                    } header: {
                        Text(LocalizedString.difficulty)
                    }
                    Section {
                        ForEach(Language.allCases, id: \.self) { language in
                            Button {
                                store.dispatch(.updateLanguage(language))
                            } label: {
                                Text(language.flagEmoji + " " + language.displayName)
                                    .fontWeight(store.state.settingsState.language == language ? .medium : .light)
                                    .foregroundStyle(store.state.settingsState.language == language ? Color.accentColor : Color.primary)
                            }
                            .listRowBackground(store.state.settingsState.language == language ? Color.gray.opacity(0.3) : Color.white)
                        }
                    } header: {
                        Text(LocalizedString.language)
                    }
                }
                .frame(maxHeight: .infinity)
                Button("\(store.state.settingsState.language.flagEmoji) \(LocalizedString.newStory) (\(store.state.settingsState.difficulty.title))") {
                    store.dispatch(.continueStory(story: store.state.createNewStory()))
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .navigationTitle(store.state.storyState.currentStory == nil ? LocalizedString.createStory : LocalizedString.storySettings)
            }
        }
    }
}
