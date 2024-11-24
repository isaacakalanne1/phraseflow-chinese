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
        VStack {
            Text("Difficulty")
                .fontWeight(.light)
                .greyBackground()
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.dispatch(.updateDifficulty(difficulty))
                            }
                        }) {
                            Text(difficulty.title)
                                .font(.body)
                                .foregroundColor(store.state.settingsState.difficulty == difficulty ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(store.state.settingsState.difficulty == difficulty ? Color.accentColor : Color.gray.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            Text("Language")
                .fontWeight(.light)
                .greyBackground()
            List {
                ForEach(Language.allCases, id: \.self) { language in
                    Button {
                        store.dispatch(.updateLanguage(language))
                    } label: {
                        Text(language.flagEmoji + " " + language.name)
                            .fontWeight(.medium)
                            .foregroundStyle(store.state.settingsState.language == language ? Color.accentColor : Color.primary)
                    }
                    .listRowBackground(store.state.settingsState.language == language ? Color.gray.opacity(0.3) : Color.white)
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
    }
}
