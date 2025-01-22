//
//  StoryPromptSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct StoryPromptOnboardingView: View {
    var body: some View {
        VStack {
            StoryPromptMenu()
            CreateStoryButton()
        }
        .background(FlowTaleColor.background)
    }
}

struct StoryPromptMenu: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        let isRandomPromptSelected = store.state.settingsState.storySetting == .random

        let isShowingAlert: Binding<Bool> = .init {
            store.state.viewState.isShowingCustomPromptAlert
        } set: { newValue in
            store.dispatch(.updateIsShowingCustomPromptAlert(newValue))
        }

        let customPrompt: Binding<String> = .init {
            store.state.settingsState.customPrompt
        } set: { newValue in
            store.dispatch(.updateCustomPrompt(newValue))
        }

        List {
            Section {

                Button {
                    store.dispatch(.updateIsShowingCustomPromptAlert(true))
                } label: {
                    //
                    Text(LocalizedString.customStory)
                        .fontWeight(.light)
                        .foregroundStyle(FlowTaleColor.primary)
                }
                .listRowBackground(Color(uiColor: UIColor.secondarySystemGroupedBackground))

                Button {
                    store.dispatch(.playSound(.changeSettings))
                    store.dispatch(.updateStorySetting(.random))
                } label: {
                    Text(LocalizedString.random)
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
                Text(LocalizedString.howStoryStart)
            }
        }
        .navigationTitle(LocalizedString.story)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
        .alert(LocalizedString.customStoryAlertTitle, isPresented: isShowingAlert) {
            TextField(LocalizedString.customStoryTextfieldPlaceholder, text: customPrompt)
            Button(LocalizedString.customStoryOkButton, action: submitCustomPrompt)
            Button(LocalizedString.customStoryCancelButton, role: .cancel) {
                store.dispatch(.updateIsShowingCustomPromptAlert(false))
            }
        } message: {
            Text(LocalizedString.customStoryAlertMessage)
        }
    }

    private func submitCustomPrompt() {
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

struct StoryPromptSettingsView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            StoryPromptMenu()

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding()
        }
        .background(FlowTaleColor.background)
        // Attach the alert:
        .alert(
            LocalizedString.storyDidNotPassModeration,
            isPresented: Binding<Bool>(
                get: { store.state.viewState.isShowingModerationFailedAlert },
                set: { newValue in
                    if !newValue {
                        store.dispatch(.dismissFailedModerationAlert)
                    }
                }
            ),
            actions: {
                Button(LocalizedString.failedModerationWhyButton) {
                    store.dispatch(.showModerationDetails)
                }
                Button(LocalizedString.failedModerationOkButton) {
                    store.dispatch(.dismissFailedModerationAlert)
                }
            },
            message: {
                Text(LocalizedString.failedModerationMessage)
            }
        )
        // If you are using iOS 16 NavigationStack with .navigationDestination, do that below
        .navigationDestination(
            isPresented: Binding<Bool>(
                get: { store.state.viewState.isShowingModerationDetails },
                set: {
                    if !$0 {
                        store.dispatch(.updateIsShowingModerationDetails(isShowing: false))
                    }
                }
            )
        ) {
            ModerationExplanationView()
        }
    }
}
