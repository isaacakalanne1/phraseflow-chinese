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
import Audio

public struct SentenceView: View {
    @EnvironmentObject var store: TextPracticeStore
    @State private var opacity: Double = 0
    @State private var currentPage: Int = 0

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
            updateCurrentSentence(chapter: chapter)
        }
        .onChange(of: spokenWord) {
            updateCurrentSentence(chapter: chapter)
        }
        .onChange(of: store.state.chapter) {
            updateCurrentSentence(chapter: chapter)
        }
    }

    private func updateCurrentSentence(chapter: Chapter) {
        if let sentence = chapter.sentences.first(where: { $0.timestamps.contains { $0.id == spokenWord?.id } }) {
            let targetPage = sentenceIndex(sentence, in: chapter.sentences)
            currentPage = targetPage
            store.dispatch(.updateCurrentSentence(sentence))
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
                        .font(FTFont.flowTaleHeader())
                        .foregroundColor(FTColor.primary)
                }
                .opacity(currentPage > 0 ? 1 : 0)
                
                Text("\(currentPage + 1) / \(totalPages)")
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.primary)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = min(totalPages - 1, currentPage + 1)
                        updateSelectedSentenceAndWord(chapter: chapter)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(FTFont.flowTaleHeader())
                        .foregroundColor(FTColor.primary)
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
            }
        }
        .frame(maxWidth: .infinity, alignment: language.alignment)
    }
}
