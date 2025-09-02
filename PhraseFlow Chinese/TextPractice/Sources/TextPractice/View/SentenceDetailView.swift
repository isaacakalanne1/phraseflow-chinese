//
//  SentenceDetailView.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import FTStyleKit
import SwiftUI
import TextGeneration
import Study

public struct SentenceDetailView: View {
    @EnvironmentObject var store: TextPracticeStore

    public init() {}
    
    public var body: some View {
        Group {
            if store.state.selectedDefinition != nil {
                DefinitionView(
                    isLoading: store.state.viewState.isDefining && store.state.selectedDefinition == nil,
                    viewData: createViewData(definition: store.state.selectedDefinition)
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
