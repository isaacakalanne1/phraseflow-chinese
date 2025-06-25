//
//  LanguageSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct LanguageOnboardingView: View {
    @EnvironmentObject var store: FlowTaleStore
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                LanguageMenu()

                CreateStoryButton()
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .background(FlowTaleColor.background)
            .opacity(store.state.viewState.isWritingChapter ? 0.3 : 1.0)
            .disabled(store.state.viewState.isWritingChapter)
            
            if store.state.viewState.isWritingChapter {
                LoadingProgressBar(isCentered: true)
                    .background(FlowTaleColor.background.opacity(0.9))
            }
        }
    }
}

struct LanguageMenu: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false
    let type: LanguageMenuType

    init(shouldDismissOnSelect: Bool = false,
         type: LanguageMenuType = .normal) {
        self.shouldDismissOnSelect = shouldDismissOnSelect
        self.type = type
    }

    var body: some View {
        ScrollView {
            Section {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 8) {

                    if type == .translationSourceLanguage {
                        ImageButton(
                            title: "Auto-detect",
                            image: UIImage(),
                            isSelected: store.state.translationState.sourceLanguage == nil,
                            action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.audioAction(.playSound(.changeSettings)))
                                    store.dispatch(.translationAction(.updateSourceLanguage(nil)))
                                    dismiss()
                                }
                            }
                        )
                    }
                    ForEach(Language.allCases, id: \.self) { language in
                        let isSelectedLanguage = store.state.settingsState.language == language

                        ImageButton(
                            title: language.displayName,
                            image: language.thumbnail,
                            isSelected: isSelectedLanguage,
                            action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.audioAction(.playSound(.changeSettings)))
                                    switch type {
                                    case .normal:
                                        store.dispatch(.appSettingsAction(.updateLanguage(language)))
                                    case .translationSourceLanguage:
                                        store.dispatch(.translationAction(.updateSourceLanguage(language)))
                                    case .translationTargetLanguage:
                                        store.dispatch(.translationAction(.updateTargetLanguage(language)))
                                    case .translationTextLanguage:
                                        store.dispatch(.translationAction(.updateTextLanguage(language)))
                                    }
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
