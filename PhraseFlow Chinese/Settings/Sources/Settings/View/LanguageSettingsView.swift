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

public struct LanguageMenu: View {
    @Environment(\.dismiss) var dismiss
    let type: LanguageMenuType
    @Binding private var selectedLanguage: Language
    private var isEnabled: Bool

    public init(
        selectedLanguage: Binding<Language>,
        isEnabled: Bool,
        type: LanguageMenuType = .normal
    ) {
        self._selectedLanguage = selectedLanguage
        self.isEnabled = isEnabled
        self.type = type
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                sectionHeader
                    .padding(.top, 8)
                
                languageGrid
                    .padding(.bottom, 16)
            }
            .padding(.horizontal)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .navigationTitle(LocalizedString.language)
        .background(FTColor.background)
        .scrollContentBackground(.hidden)
    }
    
    var languages: [Language] {
        var languages = Language.allCases
        if !type.shouldShowAutoDetect {
            languages.removeAll(where: { $0 == .autoDetect})
        }
        
        // Sort so selected language appears first
        return languages.sorted { first, second in
            if first == selectedLanguage { return true }
            if second == selectedLanguage { return false }
            return false
        }
    }
    
    @ViewBuilder
    private var languageGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ], spacing: 16) {
            
            ForEach(languages, id: \.self) { language in
                languageButton(for: language)
            }
        }
    }
    
    @ViewBuilder
    private func languageButton(for language: Language) -> some View {
        let isSelectedLanguage = selectedLanguage == language
        
        ImageButton(
            title: language.displayName,
            image: language.thumbnail,
            isSelected: isSelectedLanguage,
            action: {
                languageButtonAction(for: language)
            }
        )
        .disabled(!isEnabled)
    }
    
    @ViewBuilder
    private var sectionHeader: some View {
        HStack {
            Text(LocalizedString.whichLanguageLearn.uppercased())
                .font(FTFont.flowTaleSubHeader())
                .foregroundStyle(FTColor.primary)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    private func languageButtonAction(for language: Language) {
        withAnimation(.easeInOut) {
            selectedLanguage = language
            dismiss()
        }
    }
}

public struct LanguageSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding private var selectedLanguage: Language
    private var isEnabled: Bool

    public init(
        selectedLanguage: Binding<Language>,
        isEnabled: Bool
    ) {
        self._selectedLanguage = selectedLanguage
        self.isEnabled = isEnabled
    }

    public var body: some View {
        VStack(spacing: 0) {
            LanguageMenu(selectedLanguage: $selectedLanguage,
                         isEnabled: isEnabled)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FTColor.background)
    }
}
