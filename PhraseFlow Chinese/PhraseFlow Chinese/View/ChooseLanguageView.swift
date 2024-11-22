//
//  ChooseLanguageView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 22/11/2024.
//

import SwiftUI

struct ChooseLanguageView: View {
    @EnvironmentObject var store: FastChineseStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            List {
                ForEach(Language.allCases, id: \.self) { language in
                    Button {
                        store.dispatch(.updateLanguage(language))
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(language.flagEmoji + " " + language.name)
                            .fontWeight(.medium)
                            .foregroundStyle(store.state.settingsState.language == language ? Color.accentColor : Color.primary)
                    }
                    .listRowBackground(store.state.settingsState.language == language ? Color.gray.opacity(0.3) : .clear)
                }
            }
        }
        .navigationTitle("Choose Language")
    }
}
