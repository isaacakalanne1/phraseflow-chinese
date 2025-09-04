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
            switch store.state.viewState {
            case .normal:
                if store.state.isShowingOriginalSentence {
                    TranslatedSentenceView()
                        .frame(maxHeight: .infinity)
                        .cardBackground()
                }
            case .showDefinition:
                DefinitionView(
                    isLoading: store.state.selectedDefinition == nil,
                    viewData: createViewData(definition: store.state.selectedDefinition)
                )
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
