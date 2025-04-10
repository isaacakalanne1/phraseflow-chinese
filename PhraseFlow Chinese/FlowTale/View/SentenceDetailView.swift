//
//  SentenceDetailView.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI

struct SentenceDetailView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        Group {
            if (store.state.viewState.isDefining || store.state.definitionState.currentDefinition != nil) && store.state.settingsState.isShowingDefinition {
                DefinitionView(definition: store.state.definitionState.currentDefinition)
                    .frame(height: 200)
                    .cardBackground()
            } else if store.state.settingsState.isShowingEnglish {
                TranslatedSentenceView()
                    .frame(height: 200)
                    .cardBackground()
            }
        }
    }
}
