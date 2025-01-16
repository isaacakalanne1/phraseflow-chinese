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

        let isRandomPromptSelected = store.state.settingsState.storySetting == .random

        let customPrompt: Binding<String> = .init {
            store.state.settingsState.customPrompt
        } set: { newValue in
            store.dispatch(.updateCustomPrompt(newValue))
        }

        let isShowingAlert: Binding<Bool> = .init {
            store.state.viewState.isShowingCustomPromptAlert
        } set: { newValue in
            store.dispatch(.updateIsShowingCustomPromptAlert(newValue))
        }

        let currentDifficulty = store.state.settingsState.difficulty
        let currentLanguage = store.state.settingsState.language
        let currentStorySetting = store.state.settingsState.storySetting

        VStack {
            List {
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

                NavigationLink {
                    LanguageSettingsView()
                } label: {
                    Text(currentLanguage.flagEmoji + " " + currentLanguage.displayName)
                        .fontWeight(.light)
                        .foregroundStyle(FlowTaleColor.primary)
                }

                NavigationLink {
                    StoryPromptSettingsView()
                } label: {
                    Text("\(currentStorySetting.emoji) Story: \(currentStorySetting.title)")
                        .fontWeight(.light)
                        .foregroundStyle(FlowTaleColor.primary)
                        .lineLimit(1)
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
        .alert("Custom", isPresented: isShowingAlert) {
            TextField("Custom story", text: customPrompt)
            Button("OK", action: submitCustomPrompt)
            Button("Cancel", role: .cancel) {
                store.dispatch(.updateIsShowingCustomPromptAlert(false))
            }
        } message: {
            Text("Enter your custom story setting")
        }
    }

    func submitCustomPrompt() {
        store.dispatch(.showSnackBar(.moderatingText))
        store.dispatch(.updateIsShowingCustomPromptAlert(false))
        store.dispatch(.updateStorySetting(.customPrompt(store.state.settingsState.customPrompt)))
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first,
              let prompt = store.state.settingsState.customPrompts[safe: index] else { return }
        store.dispatch(.deleteCustomPrompt(prompt))
    }
}
