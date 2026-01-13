//
//  SentenceView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
import FTColor
import FTFont
import FTStyleKit
import TextGeneration
import Localization
import Settings

public struct SentenceView: View {
    @EnvironmentObject var store: TextPracticeStore
    @State private var opacity: Double = 0
    @State private var currentPage: Int = 0
    @State private var wordFrames: [UUID: CGRect] = [:]
    @State private var lastSelectedWordId: UUID? = nil

    var spokenWord: WordTimeStampData? {
        store.state.chapter.currentSpokenWord
    }
    
    private func sentenceIndex(_ targetSentence: Sentence?, in sentences: [Sentence]) -> Int {
        guard let targetSentence,
              let sentenceIndex = sentences.firstIndex(of: targetSentence) else {
            return 0
        }
        return sentenceIndex
    }
    
    var isLastPage: Bool {
        currentPage == store.state.chapter.sentences.count - 1
    }
    
    var chapter: Chapter {
        store.state.chapter
    }

    public var body: some View {
        paginatedView()
    }

    @ViewBuilder
    func paginatedView() -> some View {
        VStack(spacing: 16) {
            flowLayout(sentence: chapter.sentences[currentPage],
                       language: chapter.language)
                .frame(maxWidth: .infinity, alignment: .leading)
                .coordinateSpace(name: "sentenceView")
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let location = value.location
                            if let wordId = wordFrames.first(where: { $0.value.contains(location) })?.key,
                               wordId != lastSelectedWordId {
                                if let word = chapter.sentences[currentPage].timestamps.first(where: { $0.id == wordId }) {
                                    store.dispatch(.selectWord(word))
                                    lastSelectedWordId = wordId
                                }
                            }
                        }
                        .onEnded { _ in
                            lastSelectedWordId = nil
                            store.dispatch(.hideDefinition)
                        }
                )

            paginationControls(totalPages: chapter.sentences.count,
                               chapter: chapter)

            playbackControls
            
            if isLastPage,
               store.state.textPracticeType == .story {
                MainButton(title: LocalizedString.newChapter.uppercased()) {
                    store.dispatch(.goToNextChapter)
                }
                .disabled(store.state.isWritingNewChapter)
            }
        }
        .onAppear {
            opacity = 1
            updateCurrentSentence()
        }
        .onChange(of: spokenWord) {
            updateCurrentSentence()
        }
        .onChange(of: store.state.chapter) {
            updateCurrentSentence()
        }
        .onChange(of: currentPage) { _ in
            wordFrames = [:]
        }
    }

    private func updateCurrentSentence() {
        if let sentence = chapter.sentences.first(where: { $0.timestamps.contains { $0.id == spokenWord?.id } }) {
            let targetPage = sentenceIndex(sentence, in: chapter.sentences)
            currentPage = targetPage
            
            // Only update if the sentence has actually changed to avoid clearing definitions unnecessarily
            if chapter.currentSentence?.id != sentence.id {
                store.dispatch(.updateCurrentSentence(sentence))
            }
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 16) {
            AudioButton()
            SpeechSpeedButton()
        }
    }
    
    @ViewBuilder
    private func paginationControls(totalPages: Int, chapter: Chapter) -> some View {
        if totalPages > 1 {
            HStack(spacing: 16) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = max(0, currentPage - 1)
                        updateSelectedSentenceAndWord(chapter: chapter)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(FTFont.header.font)
                        .foregroundColor(FTColor.primary.color)
                }
                .opacity(currentPage > 0 ? 1 : 0)
                
                Text("\(currentPage + 1) / \(totalPages)")
                    .font(FTFont.secondaryHeader.font)
                    .foregroundColor(FTColor.primary.color)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = min(totalPages - 1, currentPage + 1)
                        updateSelectedSentenceAndWord(chapter: chapter)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(FTFont.header.font)
                        .foregroundColor(FTColor.primary.color)
                }
                .opacity(currentPage < totalPages - 1 ? 1 : 0)
            }
            .padding(.vertical, 8)
        }
    }

    private func updateSelectedSentenceAndWord(chapter: Chapter) {
        let sentence = chapter.sentences[currentPage]
        store.dispatch(.updateCurrentSentence(sentence))
        if let timestamp = sentence.timestamps.first {
            store.dispatch(.setPlaybackTime(timestamp.time))
        }
    }

    private func flowLayout(sentence: Sentence,
                            language: Language) -> some View {
        FlowLayout(spacing: 0, language: language) {
            ForEach(Array(sentence.timestamps.enumerated()), id: \.offset) { index, word in
                CharacterView(word: word, sentence: sentence)
                    .id(word.id)
                    .opacity(opacity)
                    .animation(.easeInOut.delay(Double(index) * 0.02), value: opacity)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    wordFrames[word.id] = geo.frame(in: .named("sentenceView"))
                                }
                                .onChange(of: geo.frame(in: .named("sentenceView"))) { newFrame in
                                    wordFrames[word.id] = newFrame
                                }
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: language.alignment)
    }
}
