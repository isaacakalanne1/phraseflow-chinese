//
//  DifficultySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct DifficultyOnboardingView: View {
    var body: some View {
        VStack {
            DifficultyMenu()
            NavigationLink {
                StoryPromptOnboardingView()
            } label: {
                PrimaryButton(title: LocalizedString.next)
            }
        }
        .background(FlowTaleColor.background)
    }
}

struct DifficultyMenu: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

    var body: some View {
        List {
            Section {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Button {
                        store.dispatch(.playSound(.changeSettings))
                        store.dispatch(.updateDifficulty(difficulty))
                        if shouldDismissOnSelect {
                            dismiss()
                        }
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
                Text(LocalizedString.howDifficultStory)
            }
        }
        .navigationTitle(LocalizedString.difficulty)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
    }
}

struct DifficultySettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            DifficultyMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding()
        }
        .background(FlowTaleColor.background)
    }
}
