//
//  TranslationResultsSection.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Localization
import SwiftUI
import FTFont
import FTColor
import FTStyleKit
import TextGeneration
import Study
import Story

struct TranslationResultsSection: View {
    @EnvironmentObject var store: TranslationStore
    let chapter: Chapter
    
    var currentSentence: Sentence? {
        guard store.state.currentSentenceIndex < chapter.sentences.count else { return nil }
        return chapter.sentences[store.state.currentSentenceIndex]
    }
    
    var totalSentences: Int {
        chapter.sentences.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Navigation arrows and sentence counter
            HStack {
                Button {
                    let newIndex = max(0, store.state.currentSentenceIndex - 1)
                    store.dispatch(.updateCurrentSentenceIndex(newIndex))
                } label: {
                    Image(systemName: "chevron.left")
                        .font(FTFont.flowTaleHeader())
                        .foregroundColor(store.state.currentSentenceIndex > 0 ? .primary : .gray)
                }
                .disabled(store.state.currentSentenceIndex <= 0)
                
                Text("\(store.state.currentSentenceIndex + 1) / \(totalSentences)")
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(.secondary)
                
                Button {
                    let newIndex = min(totalSentences - 1, store.state.currentSentenceIndex + 1)
                    store.dispatch(.updateCurrentSentenceIndex(newIndex))
                } label: {
                    Image(systemName: "chevron.right")
                        .font(FTFont.flowTaleHeader())
                        .foregroundColor(store.state.currentSentenceIndex < totalSentences - 1 ? .primary : .gray)
                }
                .disabled(store.state.currentSentenceIndex >= totalSentences - 1)
            }
            .padding(.vertical, 8)
            
            // Original sentence (always shown with translation)
            if let sentence = currentSentence {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Original")
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.secondary)
                    
                    Text(sentence.original)
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
                .cardBackground()
            }
            
            // Translated sentence with word interaction
            if let sentence = currentSentence {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Translation")
                            .font(FTFont.flowTaleSecondaryHeader())
                            .foregroundColor(FTColor.secondary)
                        
                        Spacer()
                        
                        Button {
                            if store.state.isPlayingAudio {
                                store.dispatch(.pauseTranslationAudio)
                            } else {
                                store.dispatch(.playTranslationAudio)
                            }
                        } label: {
                            Image(systemName: store.state.isPlayingAudio ?
                                  "pause.circle.fill" : "play.circle.fill")
                                .foregroundColor(FTColor.accent)
                        }
                    }
                    
                    TranslationSentenceWordsView(sentence: sentence)
                }
                .padding(12)
                .cardBackground()
            }
            
            // Definition view
            if let definition = store.state.currentDefinition {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Definition")
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.secondary)
                    
                    DefinitionView(
                        isLoading: false,
                        viewData: DefinitionViewData(
                            word: definition.word,
                            pronounciation: definition.pronunciation,
                            definition: definition.definition,
                            definitionInContextOfSentence: definition.definitionInContextOfSentence
                        )
                    )
                }
                .padding(12)
                .cardBackground()
            }
        }
    }
}

struct TranslationSentenceWordsView: View {
    @EnvironmentObject var store: TranslationStore
    let sentence: Sentence
    
    var body: some View {
        FlowLayout(spacing: 0, language: store.state.targetLanguage) {
            ForEach(Array(sentence.timestamps.enumerated()), id: \.offset) { index, word in
                TranslationWordView(word: word, sentence: sentence)
                    .id(word.id)
            }
        }
        .frame(maxWidth: .infinity, alignment: store.state.targetLanguage.alignment)
    }
}

struct TranslationWordView: View {
    @EnvironmentObject var store: TranslationStore
    let word: WordTimeStampData
    let sentence: Sentence
    
    var isTappedWord: Bool {
        store.state.currentDefinition?.timestampData == word
    }
    
    var hasDefinition: Bool {
        let key = DefinitionKey(word: word.word, sentenceId: sentence.id)
        return store.state.definitions[key] != nil
    }
    
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(word.word)
                    .font(FTFont.flowTaleBodyMedium())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(isTappedWord ? FTColor.primary : FTColor.primary)
                    .background {
                        if !hasDefinition {
                            GeometryReader { geometry in
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        FTColor.highlight.opacity(0.4),
                                        FTColor.highlight.opacity(0.8),
                                        FTColor.highlight.opacity(0.4),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: geometry.size.width * 2, height: geometry.size.height)
                                .offset(x: shimmerOffset * (geometry.size.width + 50) - geometry.size.width - 25)
                                .onAppear {
                                    withAnimation(
                                        Animation.linear(duration: 1.2)
                                            .repeatForever(autoreverses: false)
                                    ) {
                                        shimmerOffset = 1
                                    }
                                }
                            }
                            .clipped()
                        } else if isTappedWord {
                            FTColor.wordHighlight
                        } else {
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
                    store.dispatch(.selectTranslationWord(word))
                }
                .onEnded { _ in
                    store.dispatch(.clearTranslationDefinition)
                }
        )
    }
}

