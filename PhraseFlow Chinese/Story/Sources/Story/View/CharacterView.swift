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
    @EnvironmentObject var store: StoryStore

    let word: WordTimeStampData
    let sentence: Sentence
    let isTranslation: Bool

    var isTappedWord: Bool {
        store.environment.getCurrentDefinition()?.timestampData == word
    }

    var spokenWord: WordTimeStampData? {
        store.state.currentChapter?.currentSpokenWord
    }

    var currentSentence: Sentence? {
        isTranslation ? store.environment.getCurrentTranslationSentence() : store.state.currentChapter?.currentSentence
    }

    var hasDefinition: Bool {
        store.environment.hasDefinition(for: word)
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
                            FTColor.highlight
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
                .onChanged { isTapped in
                    switch isTranslation {
                    case true:
                        // Translation functionality handled through environment
                        break
                    case false:
                        store.dispatch(.selectWord(word, playAudio: true))
                    }
                }
                .onEnded { _ in
                    switch isTranslation {
                    case true:
                        // Translation functionality handled through environment
                        break
                    case false:
                        // Definition functionality handled through environment
                        break
                    }
                }
        )
    }
}
