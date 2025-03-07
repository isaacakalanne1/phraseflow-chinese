//
//  StoryPromptSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct StoryPromptOnboardingView: View {
    @EnvironmentObject var store: FlowTaleStore
    @State private var navigateToVoice = false
    
    var body: some View {
        VStack {
            StoryPromptMenu()
            
            PrimaryButton(title: LocalizedString.next) {
                navigateToVoice = true
            }
        }
        .background(FlowTaleColor.background)
        .navigationDestination(isPresented: $navigateToVoice) {
            VoiceOnboardingView()
        }
    }
}

struct StoryPromptMenu: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

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

        ScrollView {
            VStack(alignment: .leading) {
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        // Random Story Button
                        ImageSelectionButton(
                            title: LocalizedString.random,
                            image: UIImage(named: "StoryPrompt-Random"),
                            fallbackText: "🎲",
                            isSelected: isRandomPromptSelected,
                            action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.changeSettings))
                                    store.dispatch(.updateStorySetting(.random))
                                    if shouldDismissOnSelect {
                                        dismiss()
                                    }
                                }
                            }
                        )
                        
                        // Create Custom Story Button
                        ImageSelectionButton(
                            title: LocalizedString.customStory,
                            image: UIImage(named: "StoryPrompt-Create"),
                            fallbackText: "✏️",
                            isSelected: false,
                            action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.changeSettings))
                                    store.dispatch(.updateIsShowingCustomPromptAlert(true))
                                }
                            }
                        )
                        
                        // Previously Created Custom Stories
                        ForEach(store.state.settingsState.customPrompts, id: \.self) { prompt in
                            let isSelectedPrompt = store.state.settingsState.storySetting == .customPrompt(prompt)
                            let firstLetter = prompt.prefix(1).capitalized
                            let remainingLetters = prompt.dropFirst()
                            let displayPrompt = firstLetter + remainingLetters
                            
                            ImageSelectionButton(
                                title: displayPrompt,
                                image: UIImage(named: "StoryPrompt-Custom"),
                                fallbackText: "📝",
                                isSelected: isSelectedPrompt,
                                useFullButtonText: true,
                                action: {
                                    withAnimation(.easeInOut) {
                                        store.dispatch(.playSound(.changeSettings))
                                        store.dispatch(.updateStorySetting(.customPrompt(prompt)))
                                        if shouldDismissOnSelect {
                                            dismiss()
                                        }
                                    }
                                }
                            )
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.dispatch(.deleteCustomPrompt(prompt))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    Text(LocalizedString.howStoryStart.uppercased())
                        .font(.footnote)
                }
            }
        }
        .padding()
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
            StoryPromptMenu(shouldDismissOnSelect: true)

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
