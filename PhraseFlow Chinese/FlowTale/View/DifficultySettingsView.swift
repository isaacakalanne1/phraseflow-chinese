//
//  DifficultySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct DifficultyOnboardingView: View {
    @State private var navigateToStoryPrompt = false
    
    var body: some View {
        VStack(spacing: 0) {
            DifficultyMenu()
            
            PrimaryButton(title: LocalizedString.next) {
                navigateToStoryPrompt = true
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FlowTaleColor.background)
        .navigationDestination(isPresented: $navigateToStoryPrompt) {
            StoryPromptOnboardingView()
        }
    }
}

struct DifficultyMenu: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            let isSelectedDifficulty = store.state.settingsState.difficulty == difficulty
                            
                            ImageSelectionButton(
                                title: difficulty.title,
                                image: difficulty.thumbnail,
                                fallbackText: difficulty.emoji,
                                isSelected: isSelectedDifficulty,
                                action: {
                                    withAnimation(.easeInOut) {
                                        store.dispatch(.playSound(.changeSettings))
                                        store.dispatch(.updateDifficulty(difficulty))
                                        if shouldDismissOnSelect {
                                            dismiss()
                                        }
                                    }
                                }
                            )
                        }
                    }
                } header: {
                    Text(LocalizedString.howDifficultStory.uppercased())
                        .font(.footnote)
                }
            }
        }
        .padding()
        .navigationTitle(LocalizedString.difficulty)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
    }
}

struct DifficultySettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            DifficultyMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FlowTaleColor.background)
    }
}
