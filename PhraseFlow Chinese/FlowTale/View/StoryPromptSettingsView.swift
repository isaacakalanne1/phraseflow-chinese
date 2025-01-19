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
                    Text("Custom Story...")
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
        .navigationTitle("How do you want the story to start?")
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
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

            PrimaryButton(title: "Done") {
                dismiss()
            }
            .padding()
        }
    }

}
