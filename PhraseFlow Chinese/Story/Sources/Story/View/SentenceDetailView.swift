//
//  SentenceDetailView.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import FTStyleKit
import SwiftUI
import TextGeneration

struct SentenceDetailView: View {
    @EnvironmentObject var store: StoryStore

    var body: some View {
        Group {
            if (store.state.isDefining || store.state.currentDefinition != nil) && store.state.isShowingDefinition {
                DefinitionView(
                    isLoading: store.state.viewState.isDefining,
                    viewData: createViewData(definition: store.environment.getCurrentDefinition())
                )
                .frame(maxHeight: .infinity)
                .cardBackground()
                    
            } else if (try? store.environment.isShowingEnglish()) == true {
                TranslatedSentenceView()
                    .frame(maxHeight: .infinity)
                    .cardBackground()
            }
        }
    }
    
    func createViewData(definition: Definition?) -> DefinitionViewData? {
        guard let definition else { return nil }
        return DefinitionViewData(word: definition.word,
                                  pronounciation: definition.pronunciation,
                                  definition: definition.definition,
                                  definitionInContextOfSentence: definition.definitionInContextOfSentence)
    }
}
