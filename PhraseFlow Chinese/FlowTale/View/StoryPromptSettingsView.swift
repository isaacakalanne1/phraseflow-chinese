//
//  StoryPromptSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct StoryPromptSettingsView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        let isRandomPromptSelected = store.state.settingsState.storySetting == .random
        
        List {
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
        .navigationTitle("Story")
        .background(FlowTaleColor.background)
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first,
              let prompt = store.state.settingsState.customPrompts[safe: index] else { return }
        store.dispatch(.deleteCustomPrompt(prompt))
    }
}
