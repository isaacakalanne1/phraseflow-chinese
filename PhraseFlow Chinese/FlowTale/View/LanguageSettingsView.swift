//
//  LanguageSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 16/01/2025.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var store: FlowTaleStore
    
    var body: some View {
        List {
            Section {
                ForEach(Language.allCases, id: \.self) { language in
                    Button {
                        store.dispatch(.playSound(.changeSettings))
                        store.dispatch(.updateLanguage(language))
                    } label: {
                        Text(language.flagEmoji + " " + language.displayName)
                            .fontWeight(store.state.settingsState.language == language ? .medium : .light)
                            .foregroundStyle(store.state.settingsState.language == language ? FlowTaleColor.accent : FlowTaleColor.primary)
                    }
                    .listRowBackground(store.state.settingsState.language == language ? FlowTaleColor.secondary : Color(uiColor: UIColor.secondarySystemGroupedBackground))
                }
            } header: {
                Text(LocalizedString.language)
            }
        }
        .navigationTitle("Language")
        .background(FlowTaleColor.background)
    }
}
