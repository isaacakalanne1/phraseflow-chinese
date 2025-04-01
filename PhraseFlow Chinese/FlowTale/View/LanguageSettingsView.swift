//
//  LanguageSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct LanguageOnboardingView: View {
    @State private var navigateToDifficulty = false
    
    var body: some View {
        VStack(spacing: 0) {
            LanguageMenu()
            
            PrimaryButton(title: LocalizedString.next) {
                navigateToDifficulty = true
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FlowTaleColor.background)
        .navigationDestination(isPresented: $navigateToDifficulty) {
            DifficultyOnboardingView()
        }
    }
}

struct LanguageMenu: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Language.allCases, id: \.self) { language in
                            let isSelectedLanguage = store.state.settingsState.language == language
                            
                            ImageSelectionButton(
                                title: language.displayName,
                                image: language.thumbnail,
                                fallbackText: language.flagEmoji,
                                isSelected: isSelectedLanguage,
                                action: {
                                    withAnimation(.easeInOut) {
                                        store.dispatch(.playSound(.changeSettings))
                                        store.dispatch(.updateLanguage(language))
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
                    Text(LocalizedString.whichLanguageLearn.uppercased())
                        .font(.footnote)
                }
            }
        }
        .padding()
        .navigationTitle(LocalizedString.language)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
    }
}


struct LanguageSettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            LanguageMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FlowTaleColor.background)
    }
}
