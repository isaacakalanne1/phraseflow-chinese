//
//  ChooseLanguageView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 22/11/2024.
//

import SwiftUI

struct ChooseLanguageView: View {
    @EnvironmentObject var store: FastChineseStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Button {
                            store.dispatch(.updateDifficulty(difficulty))
                        } label: {
                            Text(difficulty.emoji + " " + difficulty.title)
                                .fontWeight(store.state.settingsState.difficulty == difficulty ? .medium : .light)
                                .foregroundStyle(store.state.settingsState.difficulty == difficulty ? Color.accentColor : Color.primary)
                        }
                        .listRowBackground(store.state.settingsState.difficulty == difficulty ? Color.gray.opacity(0.3) : Color.white)
                    }
                } header: {
                    Text("Difficulty")
                }
                Section {
                    ForEach(Language.allCases, id: \.self) { language in
                        Button {
                            store.dispatch(.updateLanguage(language))
                        } label: {
                            Text(language.flagEmoji + " " + language.name)
                                .fontWeight(store.state.settingsState.language == language ? .medium : .light)
                                .foregroundStyle(store.state.settingsState.language == language ? Color.accentColor : Color.primary)
                        }
                        .listRowBackground(store.state.settingsState.language == language ? Color.gray.opacity(0.3) : Color.white)
                    }
                } header: {
                    Text("Language")
                }
            }
            .frame(maxHeight: .infinity)
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle("Story Settings")
        .background(Color.clear)
    }
}
