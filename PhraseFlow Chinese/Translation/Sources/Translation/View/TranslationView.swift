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
    @State private var showTextLanguageSelector: Bool = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        
        let inputText: Binding<String> = .init {
            store.state.inputText
        } set: { newValue in
            store.dispatch(.updateInputText(newValue))
        }

        VStack {
            TranslationInputSection(
                inputText: inputText,
                isInputFocused: $isInputFocused
            )

            TranslationLanguageSelector(
                showLanguageSelector: $showLanguageSelector,
                showSourceLanguageSelector: $showSourceLanguageSelector,
                showTextLanguageSelector: $showTextLanguageSelector
            )
            ScrollView {
                if let chapter = store.state.chapter {
                    TextPracticeRootView(environment: store.environment.textPracticeEnvironment,
                                         chapter: chapter,
                                         definitions: store.state.definitions,
                                         type: .translator)
                }
            }
            TranslationActionButton(isInputFocused: $isInputFocused)
        }
        .padding()
        .navigationTitle(LocalizedString.translation)
        .navigationBarTitleDisplayMode(.inline)
        .background(FTColor.background)
        .navigationDestination(isPresented: $showLanguageSelector) {
            LanguageMenu(type: .translationTargetLanguage)
        }
        .navigationDestination(isPresented: $showSourceLanguageSelector) {
            LanguageMenu(type: .translationSourceLanguage)
        }
        .navigationDestination(isPresented: $showTextLanguageSelector) {
            LanguageMenu(type: .translationTextLanguage)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

