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

struct TranslationView: View {
    @EnvironmentObject var store: TranslationStore
    @State private var showLanguageSelector: Bool = false
    @State private var showSourceLanguageSelector: Bool = false
    @State private var showTextLanguageSelector: Bool = false
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack {
            ScrollView {
                TranslationInputSection(
                    inputText: $inputText,
                    isInputFocused: $isInputFocused
                )

                TranslationLanguageSelector(
                    showLanguageSelector: $showLanguageSelector,
                    showSourceLanguageSelector: $showSourceLanguageSelector,
                    showTextLanguageSelector: $showTextLanguageSelector
                )

                if let chapter = store.state.chapter {
                    TranslationResultsSection(chapter: chapter)
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
        .onChange(of: inputText, { oldValue, newValue in
            store.dispatch(.updateInputText(newValue))
        })
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

