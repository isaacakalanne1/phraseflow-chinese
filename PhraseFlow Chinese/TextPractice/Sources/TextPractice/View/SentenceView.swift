//
//  SentenceView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
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
        store.state.chapter?.currentSpokenWord
    }
    
    private func sentenceIndex(_ targetSentence: Sentence?, in sentences: [Sentence]) -> Int {
        guard let targetSentence,
              let sentenceIndex = sentences.firstIndex(of: targetSentence) else {
            return 0
        }
        return sentenceIndex
    }

    public var body: some View {
        Group {
            if let chapter = store.state.chapter {
                paginatedView(chapter: chapter)
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    func paginatedView(chapter: Chapter) -> some View {
        VStack(spacing: 16) {
            flowLayout(sentence: chapter.sentences[currentPage], language: chapter.language)
                .frame(maxWidth: .infinity, alignment: .leading)

            paginationControls(totalPages: chapter.sentences.count, chapter: chapter)

            if store.state.textPracticeType == .story {
                playbackControls
                
                let isLastPage = currentPage == chapter.sentences.count - 1
                if isLastPage {
                    MainButton(title: LocalizedString.newChapter.uppercased()) {
                        store.dispatch(.goToNextChapter)
                    }
                    .disabled(store.state.isWritingNewChapter)
                }
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
                        .foregroundColor(currentPage > 0 ? .primary : .gray)
                }
                .disabled(currentPage <= 0)
                
                Text("\(currentPage + 1) / \(totalPages)")
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(.secondary)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = min(totalPages - 1, currentPage + 1)
                        updateSelectedSentenceAndWord(chapter: chapter)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(FTFont.flowTaleHeader())
                        .foregroundColor(currentPage < totalPages - 1 ? .primary : .gray)
                }
                .disabled(currentPage >= totalPages - 1)
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
                CharacterView(word: word, sentence: sentence, isTranslation: store.state.textPracticeType == .translator)
                    .id(word.id)
                    .opacity(opacity)
                    .animation(.easeInOut.delay(Double(index) * 0.02), value: opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: language.alignment)
    }
}
