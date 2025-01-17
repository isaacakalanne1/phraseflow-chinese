//
//  DifficultySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct DifficultySettingsView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
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
            }
            
            PrimaryButton(title: "Done") {
                dismiss()
            }
            .padding()
        }
        .navigationTitle("Difficulty")
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
    }
}
