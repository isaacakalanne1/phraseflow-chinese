//
//  StoryPromptSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI
import FTColor
import FTFont
import FTStyleKit
import Localization

struct StoryPromptMenu: View {
    @EnvironmentObject var store: SettingsStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

    var body: some View {
        let isRandomPromptSelected = store.state.storySetting == .random

        let isShowingAlert: Binding<Bool> = .init {
            store.state.isShowingCustomPromptAlert
        } set: { newValue in
            store.dispatch(.updateIsShowingCustomPromptAlert(newValue))
        }

        let customPrompt: Binding<String> = .init {
            store.state.customPrompt
        } set: { newValue in
            store.dispatch(.updateCustomPrompt(newValue))
        }

        ScrollView {
            VStack(alignment: .leading) {
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 0, maximum: UIScreen.main.bounds.width / 2 - 16)),
                        GridItem(.flexible(minimum: 0, maximum: UIScreen.main.bounds.width / 2 - 16)),
                    ], spacing: 8) {
                        // Random Story Button
                        ImageButton(
                            title: LocalizedString.random,
                            image: StorySetting.random.thumbnail,
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
                        .disabled(store.state.viewState.isWritingChapter)

                        // Create Custom Story Button
                        ImageButton(
                            title: LocalizedString.customStory,
                            image: StorySetting.customPrompt("").thumbnail,
                            isSelected: false,
                            action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.changeSettings))
                                    store.dispatch(.updateIsShowingCustomPromptAlert(true))
                                }
                            }
                        )
                        .disabled(store.state.viewState.isWritingChapter)

                        // Previously Created Custom Stories
                        ForEach(store.state.customPrompts, id: \.self) { prompt in
                            let isSelectedPrompt = store.state.storySetting == .customPrompt(prompt)
                            let firstLetter = prompt.prefix(1).capitalized
                            let remainingLetters = prompt.dropFirst()
                            let displayPrompt = firstLetter + remainingLetters

                            ImageButton(
                                title: displayPrompt,
                                image: UIImage(named: "StoryPrompt-Custom"),
                                isSelected: isSelectedPrompt,
                                isTextCentered: true,
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
                            .disabled(store.state.viewState.isWritingChapter)
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.dispatch(.deleteCustomPrompt(prompt))
                                } label: {
                                    Label(LocalizedString.delete, systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    Text(LocalizedString.howStoryStart.uppercased())
                        .font(FTFont.flowTaleSubHeader())
                }
            }
        }
        .padding()
        .navigationTitle(LocalizedString.story)
        .background(FTColor.background)
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
        store.dispatch(.snackbarAction(.showSnackBar(.moderatingText)))
        store.dispatch(.updateIsShowingCustomPromptAlert(false))
        store.dispatch(.updateStorySetting(.customPrompt(store.state.customPrompt)))
    }
}

public struct StoryPromptSettingsView: View {
    @EnvironmentObject var store: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            StoryPromptMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FTColor.background)
        // Attach the alert:
        .alert(
            LocalizedString.storyDidNotPassModeration,
            isPresented: Binding<Bool>(
                get: { store.state.isShowingModerationFailedAlert },
                set: { newValue in
                    if !newValue {
                        store.dispatch(.updateIsShowingModerationFailedAlert(false))
                    }
                }
            ),
            actions: {
                Button(LocalizedString.failedModerationWhyButton) {
                    store.dispatch(.updateIsShowingModerationDetails(true))
                }
                Button(LocalizedString.failedModerationOkButton) {
                    store.dispatch(.updateIsShowingModerationFailedAlert(false))
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
                        store.dispatch(.updateIsShowingModerationDetails(false))
                    }
                }
            )
        ) {
            SimpleModerationExplanationView()
        }
    }
}

struct SimpleModerationExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.largeTitle)
                    .foregroundColor(FTColor.accent)
                
                Text(LocalizedString.contentModeration)
                    .font(FTFont.flowTaleHeader())
                    .foregroundColor(FTColor.primary)
                
                Text(LocalizedString.moderationPromptGuidelines)
                    .font(FTFont.flowTaleBodyMedium())
                    .foregroundColor(FTColor.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FTColor.background)
        .navigationTitle(LocalizedString.moderation)
        .navigationBarTitleDisplayMode(.inline)
    }
}
