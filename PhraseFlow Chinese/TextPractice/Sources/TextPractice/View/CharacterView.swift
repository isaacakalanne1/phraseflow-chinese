//
//  CharacterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
import FTFont
import FTColor
import TextGeneration

struct CharacterView: View {
    @EnvironmentObject var store: TextPracticeStore
    @State private var shimmerOffset: CGFloat = -1

    let word: WordTimeStampData
    let sentence: Sentence

    var isTappedWord: Bool {
        store.state.selectedDefinition?.timestampData == word
    }

    var spokenWord: WordTimeStampData? {
        store.state.chapter.currentSpokenWord
    }

    var currentSentence: Sentence? {
        store.state.chapter.currentSentence
    }

    var hasDefinition: Bool {
        let key = DefinitionKey(word: word.word, sentenceId: sentence.id)
        return store.state.definitions[key] != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(word.word)
                    .font(FTFont.flowTaleBodyMedium())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isTappedWord ? FTColor.primary : (word == spokenWord ? FTColor.wordHighlight : FTColor.primary))
                    .background {
                        if isTappedWord {
                            FTColor.wordHighlight
                        } else if sentence.id == currentSentence?.id {
                            Color.clear
                        }
                    }

                if isTappedWord && !hasDefinition {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(4)
                        .background(FTColor.background.opacity(0.7))
                        .cornerRadius(8)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    store.dispatch(.selectWord(word, playAudio: true))
                }
                .onEnded { _ in
                    store.dispatch(.hideDefinition)
                }
        )
    }
}
