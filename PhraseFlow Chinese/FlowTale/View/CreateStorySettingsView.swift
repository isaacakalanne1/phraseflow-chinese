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


        VStack {
            List {
                Section {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Button {
                            store.dispatch(.playSound(.changeSettings))
                            store.dispatch(.updateDifficulty(difficulty))
                        } label: {
                            HStack {
                                DifficultyView(difficulty: difficulty)
                                Text(difficulty.title)
                                    .fontWeight(store.state.settingsState.difficulty == difficulty ? .medium : .light)
                                    .foregroundStyle(store.state.settingsState.difficulty == difficulty ? FlowTaleColor.accent : FlowTaleColor.primary)
                            }
                        }
                        .listRowBackground(store.state.settingsState.difficulty == difficulty ? FlowTaleColor.secondary : Color(uiColor: UIColor.secondarySystemGroupedBackground))
                    }
                } header: {
                    Text(LocalizedString.difficulty)
                }
                Section {
                    ForEach(Language.allCases, id: \.self) { language in
                        Button {
                            store.dispatch(.playSound(.changeSettings))
                            store.dispatch(.updateLanguage(language))
                        } label: {
                            Text(language.flagEmoji + " " + language.displayName)
                                .fontWeight(store.state.settingsState.language == language ? .medium : .light)
                                .foregroundStyle(store.state.settingsState.language == language ? FlowTaleColor.accent : FlowTaleColor.primary)
                        }
                        .listRowBackground(store.state.settingsState.language == language ? FlowTaleColor.secondary : Color(uiColor: UIColor.secondarySystemGroupedBackground))
                    }
                } header: {
                    Text(LocalizedString.language)
                }
                Section {

                    Button {
                        store.dispatch(.updateIsShowingCustomPromptAlert(true))
                    } label: {
                        Text("Custom Prompt...")
                            .fontWeight(.light)
                            .foregroundStyle(FlowTaleColor.primary)
                    }
                    .listRowBackground(Color(uiColor: UIColor.secondarySystemGroupedBackground))
                    
                    Button {
                        store.dispatch(.playSound(.changeSettings))
                        store.dispatch(.updateStorySetting(.random))
                    } label: {
                        Text("Random")
                            .fontWeight(isRandomPromptSelected ? .medium : .light)
                            .foregroundStyle(isRandomPromptSelected ? FlowTaleColor.accent : FlowTaleColor.primary)
                    }
                    .listRowBackground(isRandomPromptSelected ? FlowTaleColor.secondary : Color(uiColor: UIColor.secondarySystemGroupedBackground))

                    ForEach(store.state.settingsState.customPrompts, id: \.self) { prompt in
                        let isSelectedPrompt = store.state.settingsState.storySetting == .customPrompt(prompt)
                        
                        Button {
                            store.dispatch(.playSound(.changeSettings))
                            store.dispatch(.updateStorySetting(.customPrompt(prompt)))
                        } label: {
                            Text(prompt.capitalized)
                                .fontWeight(isSelectedPrompt ? .medium : .light)
                                .foregroundStyle(isSelectedPrompt ? FlowTaleColor.accent : FlowTaleColor.primary)
                        }
                        .listRowBackground(isSelectedPrompt ? FlowTaleColor.secondary : Color(uiColor: UIColor.secondarySystemGroupedBackground))
                    }
                    .onDelete(perform: delete)
                } header: {
                    Text("Setting")
                }
            }
            .frame(maxHeight: .infinity)

            Button {
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
