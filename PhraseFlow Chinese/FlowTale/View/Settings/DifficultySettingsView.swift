//
//  DifficultySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct DifficultyMenu: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

    var body: some View {
        ScrollView {
            Section {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 8) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        let isSelectedDifficulty = store.state.settingsState.difficulty == difficulty

                        ImageButton(
                            title: difficulty.title,
                            image: difficulty.thumbnail,
                            isSelected: isSelectedDifficulty,
                            action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.audioAction(.playSound(.changeSettings)))
                                    store.dispatch(.appSettingsAction(.updateDifficulty(difficulty)))
                                    if shouldDismissOnSelect {
                                        dismiss()
                                    }
                                }
                            }
                        )
                        .disabled(store.state.viewState.isWritingChapter)
                    }
                }
            } header: {
                Text(LocalizedString.howDifficultStory.uppercased())
                    .font(.flowTaleSubHeader())
            }
        }
        .padding()
        .navigationTitle(LocalizedString.difficulty)
        .background(.ftBackground)
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
        .background(.ftBackground)
    }
}
