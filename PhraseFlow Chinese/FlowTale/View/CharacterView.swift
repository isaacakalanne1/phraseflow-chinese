//
//  CharacterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var store: FlowTaleStore

    let word: WordTimeStampData
    let isHighlighted: Bool
    let isCurrentSentence: Bool
    let isTranslation: Bool

    var isTappedWord: Bool {
        store.state.definitionState.currentDefinition?.timestampData == word
    }
    
    var hasDefinition: Bool {
        store.state.definitionState.definition(timestampData: word) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(word.word)
                    .font(.system(size: 25, weight: .light))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isTappedWord ? FlowTaleColor.primary : (isHighlighted ? FlowTaleColor.wordHighlight : FlowTaleColor.primary))
                    .background {
                        if isTappedWord {
                            FlowTaleColor.wordHighlight
                        } else if isCurrentSentence {
                            FlowTaleColor.highlight
                        }
                    }
                
                // Show a loading indicator when this word is tapped but its definition is still loading
                if isTappedWord && !hasDefinition {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(4)
                        .background(FlowTaleColor.background.opacity(0.7))
                        .cornerRadius(8)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { isTapped in
                    let definition = isTranslation ? store.state.translationState.currentDefinition : store.state.definitionState.currentDefinition
                    if definition == nil {
                        if isTranslation {
                            store.dispatch(.translationAction(.selectTranslationWord(word)))
                        } else {
                            store.dispatch(.updateAutoScrollEnabled(isEnabled: false))
                            store.dispatch(.audioAction(.playWord(word,
                                                                  story: store.state.storyState.currentStory)))

                            if let existingDefinition = store.state.definitionState.definition(timestampData: word) {
                                store.dispatch(.definitionAction(.onDefinedCharacter(existingDefinition)))
                            }
                        }
                    }
                }
                .onEnded { _ in
                    if isTranslation {
                        store.dispatch(.translationAction(.clearTranslationDefinition))
                    } else {
                        store.dispatch(.clearCurrentDefinition)
                    }
                }
        )
    }
}
