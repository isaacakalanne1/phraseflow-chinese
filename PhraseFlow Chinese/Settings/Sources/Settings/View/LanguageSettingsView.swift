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
        VStack(spacing: 20) {
            sectionHeader
                .padding(.top, 8)
            
            selectedLanguageSection

            ScrollView {
                otherLanguagesGrid
                    .padding(.bottom, 16)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        .navigationTitle(LocalizedString.language)
        .background(FTColor.background.color)
    }
    
    var availableLanguages: [Language] {
        var languages = Language.allCases
        if !type.shouldShowAutoDetect {
            languages.removeAll(where: { $0 == .autoDetect})
        }
        return languages
    }
    
    var otherLanguages: [Language] {
        availableLanguages.filter { $0 != selectedLanguage }
    }
    
    @ViewBuilder
    private var selectedLanguageSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("CURRENT SELECTION")
                    .font(FTFont.subHeader.font)
                    .foregroundStyle(FTColor.accent.color)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            selectedLanguageCard
        }
    }
    
    @ViewBuilder
    private var selectedLanguageCard: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                if let image = selectedLanguage.thumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedLanguage.displayName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(FTColor.accent.color)
                        .multilineTextAlignment(.leading)
                    
                    Text("Currently Selected")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(FTColor.primary.color.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(FTColor.accent.color)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    FTColor.accent.color.opacity(0.1),
                                    FTColor.accent.color.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(FTColor.accent.color.opacity(0.3), lineWidth: 2)
            )
        }
        .disabled(true)
    }
    
    @ViewBuilder
    private var otherLanguagesGrid: some View {
        VStack(spacing: 12) {
            HStack {
                Text("OTHER LANGUAGES")
                    .font(FTFont.subHeader.font)
                    .foregroundStyle(FTColor.primary.color)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 16) {
                
                ForEach(otherLanguages, id: \.self) { language in
                    languageButton(for: language)
                }
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
                .font(FTFont.subHeader.font)
                .foregroundStyle(FTColor.primary.color)
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
        .background(FTColor.background.color)
    }
}
