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
                                HStack {
                                    DifficultyView(difficulty: difficulty)
                                    Text(difficulty.title)
                                        .fontWeight(store.state.settingsState.difficulty == difficulty ? .medium : .light)
                                        .foregroundStyle(store.state.settingsState.difficulty == difficulty ? FlowTaleColor.accent : FlowTaleColor.primary)
                                }
                            }
                            .listRowBackground(store.state.settingsState.difficulty == difficulty ? FlowTaleColor.secondary : FlowTaleColor.background)
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
                                    .foregroundStyle(store.state.settingsState.language == language ? FlowTaleColor.accent : FlowTaleColor.primary)
                            }
                            .listRowBackground(store.state.settingsState.language == language ? FlowTaleColor.secondary : FlowTaleColor.background)
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
                .background(FlowTaleColor.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .navigationTitle(store.state.storyState.currentStory == nil ? LocalizedString.createStory : LocalizedString.storySettings)
            }
            .background(FlowTaleColor.background)
        }
    }
}
