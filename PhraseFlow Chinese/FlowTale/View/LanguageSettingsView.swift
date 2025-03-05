//
//  LanguageSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct LanguageOnboardingView: View {
    var body: some View {
        VStack {
            LanguageMenu()
            NavigationLink {
                DifficultyOnboardingView()
            } label: {
                PrimaryButton(title: LocalizedString.next)
            }
        }
        .background(FlowTaleColor.background)
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
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(Language.allCases, id: \.self) { language in
                            let isSelectedLanguage = store.state.settingsState.language == language

                            Button(action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.playSound(.changeSettings))
                                    store.dispatch(.updateLanguage(language))
                                    if shouldDismissOnSelect {
                                        dismiss()
                                    }
                                }
                            }) {
                                VStack {
                                    Group {
                                        if let thumbnail = language.thumbnail {
                                            Image(uiImage: thumbnail)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } else {
                                            // Fallback if thumbnail is nil
                                            ZStack {
                                                Color.gray.opacity(0.3)
                                                Text(language.flagEmoji)
                                                    .font(.system(size: 40))
                                            }
                                        }
                                    }
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelectedLanguage ? FlowTaleColor.accent : Color.clear, lineWidth: 3)
                                    )

                                    Text(language.displayName)
                                        .fontWeight(isSelectedLanguage ? .bold : .regular)
                                        .foregroundColor(isSelectedLanguage ? FlowTaleColor.accent : FlowTaleColor.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .cornerRadius(12)
                            }
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
        VStack {
            LanguageMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding()
        }
        .background(FlowTaleColor.background)
    }
}
