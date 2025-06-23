//
//  ChapterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ListOfSentencesView: View {
    @EnvironmentObject var store: FlowTaleStore
    @State private var opacity: Double = 0
    @State private var availableHeight: CGFloat = 0
    @State private var sentenceHeight: CGFloat = 60
    @State private var currentPage: Int = 0

    private let isTranslation: Bool

    var spokenWord: WordTimeStampData? {
        isTranslation ? store.state.translationState.currentSpokenWord : store.state.storyState.currentSpokenWord
    }

    var currentSentence: Sentence? {
        isTranslation ? store.state.translationState.currentSentence : store.state.storyState.currentSentence
    }

    init(isTranslation: Bool = false) {
        self.isTranslation = isTranslation
    }
    
    private var sentencesPerPage: Int {
        guard availableHeight > 50 else { return 2 }
        
        let buttonHeight: CGFloat = isTranslation ? 0 : 60
        let paginationHeight: CGFloat = 40
        let minSpacing: CGFloat = 20
        let usableHeight = max(50, availableHeight - buttonHeight - paginationHeight - minSpacing)
        
        let estimatedSentenceHeight = max(40, min(sentenceHeight, 150))
        let calculatedCount = max(1, Int(usableHeight / (estimatedSentenceHeight + 8)))
        
        return max(1, min(calculatedCount, 10))
    }
    
    private func pageForSentence(_ targetSentence: Sentence?, in sentences: [Sentence]) -> Int {
        guard let targetSentence,
              let sentenceIndex = sentences.firstIndex(of: targetSentence) else {
            return 0
        }
        return sentenceIndex / sentencesPerPage
    }
    
    private func sentencesForPage(_ pageIndex: Int, from sentences: [Sentence]) -> [Sentence] {
        let startIndex = pageIndex * sentencesPerPage
        let endIndex = min(startIndex + sentencesPerPage, sentences.count)
        guard startIndex < sentences.count else { return [] }
        return Array(sentences[startIndex..<endIndex])
    }

    var body: some View {
        if let chapter = store.state.storyState.currentChapter {
            paginatedView(chapter: chapter)
        }
    }

    @ViewBuilder
    func paginatedView(chapter: Chapter) -> some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    ForEach(sentencesForPage(currentPage, from: chapter.sentences), id: \.self) { sentence in
                        flowLayout(sentence: sentence, language: chapter.language)
                            .background(
                                GeometryReader { sentenceGeometry in
                                    Color.clear
                                        .onAppear {
                                            let measuredHeight = sentenceGeometry.size.height + 8
                                            if measuredHeight > 0 && measuredHeight < 200 {
                                                sentenceHeight = max(sentenceHeight, measuredHeight)
                                            }
                                        }
                                }
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 30)
                
                Spacer()
                
                paginationControls(totalSentences: chapter.sentences.count)
                
                if !isTranslation {
                    MainButton(title: LocalizedString.newChapter.uppercased()) {
                        let allChaptersForStory = store.state.storyState.storyChapters[chapter.storyId] ?? []
                        let isLastChapter = store.state.storyState.currentChapterIndex >= allChaptersForStory.count - 1
                        
                        switch isLastChapter {
                        case true:
                            store.dispatch(.storyAction(.updateAutoScrollEnabled(isEnabled: true)))
                            store.dispatch(.audioAction(.playSound(.goToNextChapter)))
                            store.dispatch(.storyAction(.goToNextChapter))
                        case false:
                            store.dispatch(.snackbarAction(.showSnackBar(.writingChapter)))
                            store.dispatch(.storyAction(.createChapter(.existingStory(chapter.storyId))))
                        }
                    }
                    .disabled(store.state.viewState.isWritingChapter)
                }
            }
            .onAppear {
                availableHeight = geometry.size.height
                opacity = 1
                store.dispatch(.snackbarAction(.checkDeviceVolumeZero))
                let buttonHeight: CGFloat = isTranslation ? 0 : 60
                let usableHeight = max(50, availableHeight - buttonHeight - 20)
                print("📏 Available: \(availableHeight), Usable: \(usableHeight), Sentence: \(sentenceHeight), Per page: \(sentencesPerPage)")
            }
            .onChange(of: sentenceHeight) { oldValue, newValue in
                print("Sentence height updated: \(newValue), New sentences per page: \(sentencesPerPage)")
            }
            .onChange(of: currentSentence) { oldValue, newValue in
                let targetPage = pageForSentence(newValue, in: chapter.sentences)
                if targetPage != currentPage {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = targetPage
                    }
                }
            }
            .onChange(of: spokenWord) { oldValue, newValue in
                if let newValue,
                   let sentence = chapter.sentences.first(where: { $0.timestamps.contains { $0.id == newValue.id } }),
                   currentSentence != sentence {
                    if !isTranslation {
                        store.dispatch(.storyAction(.updateCurrentSentence(sentence)))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func paginationControls(totalSentences: Int) -> some View {
        let totalPages = max(1, (totalSentences + sentencesPerPage - 1) / sentencesPerPage)
        
        if totalPages > 1 {
            HStack(spacing: 16) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = max(0, currentPage - 1)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(currentPage > 0 ? .primary : .gray)
                }
                .disabled(currentPage <= 0)
                
                Text("\(currentPage + 1) / \(totalPages)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = min(totalPages - 1, currentPage + 1)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(currentPage < totalPages - 1 ? .primary : .gray)
                }
                .disabled(currentPage >= totalPages - 1)
            }
            .padding(.vertical, 8)
        }
    }

    private func flowLayout(sentence: Sentence,
                            language: Language) -> some View {
        FlowLayout(spacing: 0, language: language) {
            ForEach(Array(sentence.timestamps.enumerated()), id: \.offset) { index, word in
                CharacterView(word: word, sentence: sentence, isTranslation: isTranslation)
                    .id(word.id)
                    .opacity(opacity)
                    .animation(.easeInOut.delay(Double(index) * 0.02), value: opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: language.alignment)
    }
}
