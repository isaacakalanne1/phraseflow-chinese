//
//  TranslationView.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Localization
import SwiftUI
import FTColor
import Settings
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
            
            Spacer()
            
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
}

