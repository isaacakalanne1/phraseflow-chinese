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
    @State private var shimmerOffset: CGFloat = -1

    let word: WordTimeStampData
    let sentence: Sentence
    let isTranslation: Bool

    var isTappedWord: Bool {
        store.state.selectedDefinition?.timestampData == word
    }

    var spokenWord: WordTimeStampData? {
        store.state.currentChapter?.currentSpokenWord
    }

    var currentSentence: Sentence? {
        isTranslation ? store.environment.getCurrentTranslationSentence() : store.state.currentChapter?.currentSentence
    }

    var hasDefinition: Bool {
        store.state.definitions[word.word] != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(word.word)
                    .font(FTFont.flowTaleBodyMedium())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isTappedWord ? FTColor.primary : (word == spokenWord ? FTColor.wordHighlight : FTColor.primary))
                    .background {
                        if !hasDefinition {
                            GeometryReader { geometry in
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        FTColor.highlight.opacity(0.3),
                                        FTColor.highlight.opacity(0.6),
                                        FTColor.highlight.opacity(0.3)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height * 2)
                                .offset(y: shimmerOffset * geometry.size.height)
                                .animation(
                                    Animation.linear(duration: 1.5)
                                        .repeatForever(autoreverses: true),
                                    value: shimmerOffset
                                )
                                .onAppear {
                                    shimmerOffset = 1
                                }
                            }
                            .clipped()
                        } else if isTappedWord {
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
                .onChanged { _ in
                    switch isTranslation {
                    case true:
                        // Translation functionality handled through environment
                        break
                    case false:
                        store.dispatch(.selectWord(word, playAudio: true))
                        store.dispatch(.showDefinition(word))
                    }
                }
                .onEnded { _ in
                    switch isTranslation {
                    case true:
                        // Translation functionality handled through environment
                        break
                    case false:
                        store.dispatch(.hideDefinition)
                    }
                }
        )
    }
}
