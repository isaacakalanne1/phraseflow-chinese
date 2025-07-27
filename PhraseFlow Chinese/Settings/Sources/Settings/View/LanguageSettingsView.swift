//
//  LanguageSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import FTColor
import FTFont
import FTStyleKit
import Localization
import SwiftUI

struct LanguageOnboardingView: View {
    @EnvironmentObject var store: SettingsStore
    
    var body: some View {
        VStack(spacing: 0) {
            LanguageMenu()
        }
        .background(FTColor.background)
        .opacity(store.state.viewState.isWritingChapter ? 0.3 : 1.0)
        .disabled(store.state.viewState.isWritingChapter)
    }
}

public struct LanguageMenu: View {
    @EnvironmentObject var store: SettingsStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false
    let type: LanguageMenuType

    public init(shouldDismissOnSelect: Bool = false,
         type: LanguageMenuType = .normal) {
        self.shouldDismissOnSelect = shouldDismissOnSelect
        self.type = type
    }

    public var body: some View {
        ScrollView {
            Section {
                languageGrid
            } header: {
                sectionHeader
            }
        }
        .padding()
        .navigationTitle(LocalizedString.language)
        .background(FTColor.background)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private var languageGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 8) {
            
            ForEach(Language.allCases, id: \.self) { language in
                languageButton(for: language)
            }
        }
    }
    
    @ViewBuilder
    private func languageButton(for language: Language) -> some View {
        let isSelectedLanguage = store.state.language == language
        
        ImageButton(
            title: language.displayName,
            image: language.thumbnail,
            isSelected: isSelectedLanguage,
            action: {
                languageButtonAction(for: language)
            }
        )
        .disabled(store.state.viewState.isWritingChapter)
    }
    
    @ViewBuilder
    private var sectionHeader: some View {
        Text(LocalizedString.whichLanguageLearn.uppercased())
            .font(FTFont.flowTaleSubHeader())
    }
    
    private func languageButtonAction(for language: Language) {
        withAnimation(.easeInOut) {
            store.dispatch(.playSound(.changeSettings))
            
            switch type {
            case .normal:
                store.dispatch(.updateLanguage(language))
            case .translationSourceLanguage, .translationTargetLanguage, .translationTextLanguage:
                break
            }
            
            if shouldDismissOnSelect {
                dismiss()
            }
        }
    }
}

public struct LanguageSettingsView: View {
    @Environment(\.dismiss) var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            LanguageMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FTColor.background)
    }
}
