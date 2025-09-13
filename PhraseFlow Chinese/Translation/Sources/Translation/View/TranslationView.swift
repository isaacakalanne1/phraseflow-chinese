//
//  TranslationView.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import SwiftUI
import FTColor
import Settings
import TextGeneration
import TextPractice

struct TranslationView: View {
    @EnvironmentObject var store: TranslationStore
    @State private var showLanguageSelector: Bool = false
    @State private var showSourceLanguageSelector: Bool = false
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        let sourceLanguage: Binding<Language> = .init {
            store.state.settings.sourceLanguage
        } set: { newValue in
            store.dispatch(.updateSourceLanguage(newValue))
        }
        
        let targetLanguage: Binding<Language> = .init {
            store.state.settings.targetLanguage
        } set: { newValue in
            store.dispatch(.updateTargetLanguage(newValue))
        }

        VStack {
            TranslationInputSection(
                inputText: $inputText,
                isInputFocused: $isInputFocused
            )

            TranslationLanguageSelector(
                showLanguageSelector: $showLanguageSelector,
                showSourceLanguageSelector: $showSourceLanguageSelector
            )
            
            List {
                ForEach(Array(store.state.savedTranslations.enumerated()),
                        id: \.offset) { index, translation in
                    Button(action: {
                        store.dispatch(.selectTranslation(translation))
                    }) {
                        translationCard(translation)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let translationToDelete = store.state.savedTranslations[index]
                        store.dispatch(.deleteTranslation(translationToDelete.id))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            
            TranslationActionButton(isInputFocused: $isInputFocused)
        }
        .padding()
        .toolbar(.hidden)
        .background(FTColor.background)
        .navigationDestination(isPresented: $showLanguageSelector) {
            LanguageMenu(selectedLanguage: targetLanguage,
                         isEnabled: !store.state.isTranslating,
                         type: .translationTargetLanguage)
        }
        .navigationDestination(isPresented: $showSourceLanguageSelector) {
            LanguageMenu(selectedLanguage: sourceLanguage,
                         isEnabled: !store.state.isTranslating,
                         type: .translationSourceLanguage)
        }
        .navigationDestination(isPresented: .init(
            get: { store.state.showTextPractice },
            set: { store.dispatch(.showTextPractice($0)) }
        )) {
            if let chapter = store.state.chapter {
                TextPracticeRootView(environment: store.environment.textPracticeEnvironment,
                                     chapter: chapter,
                                     type: .translator)
            }
        }
        .onChange(of: inputText, { oldValue, newValue in
            store.dispatch(.updateInputText(newValue))
        })
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private func translationCard(_ translation: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(translation.deviceLanguage.flagEmoji)
                    .font(.system(size: 20))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(FTColor.primary.opacity(0.5))
                
                Text(translation.language.flagEmoji)
                    .font(.system(size: 20))
                
                Spacer()
                
                Text(translation.lastUpdated, style: .relative)
                    .font(.caption)
                    .foregroundColor(FTColor.primary.opacity(0.6))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(translation.sentences.prefix(2).map { $0.original }.joined(separator: " "))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(FTColor.primary)
                    .lineLimit(2)
                
                Text(translation.sentences.prefix(2).map { $0.translation }.joined(separator: " "))
                    .font(.system(size: 14))
                    .foregroundColor(FTColor.primary.opacity(0.8))
                    .lineLimit(2)
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                        .font(.caption2)
                    Text("\(translation.sentences.count) sentences")
                        .font(.caption2)
                }
                .foregroundColor(FTColor.primary.opacity(0.6))
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FTColor.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FTColor.primary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

