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

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(word.word)
                    .font(FTFont.bodyMedium.font)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isTappedWord ? FTColor.primary.color : (word == spokenWord ? FTColor.wordHighlight.color : FTColor.primary.color))
                    .background {
                        if isTappedWord {
                            FTColor.wordHighlight.color
                        } else if sentence.id == currentSentence?.id {
                            Color.clear
                        }
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
