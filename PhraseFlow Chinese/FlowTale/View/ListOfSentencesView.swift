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
    
    private func sentenceIndex(_ targetSentence: Sentence?, in sentences: [Sentence]) -> Int {
        guard let targetSentence,
              let sentenceIndex = sentences.firstIndex(of: targetSentence) else {
            return 0
        }
        return sentenceIndex
    }

    var body: some View {
        if let chapter = store.state.storyState.currentChapter {
            paginatedView(chapter: chapter)
        }
    }

    @ViewBuilder
    func paginatedView(chapter: Chapter) -> some View {
        VStack(spacing: 16) {
            flowLayout(sentence: chapter.sentences[currentPage], language: chapter.language)
                .frame(maxWidth: .infinity, alignment: .leading)

            paginationControls(totalPages: chapter.sentences.count)
            
            if !isTranslation {
                playbackControls
                
                let isLastPage = currentPage == chapter.sentences.count - 1
                if isLastPage {
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
        }
        .onAppear {
            opacity = 1
            store.dispatch(.snackbarAction(.checkDeviceVolumeZero))
            if let sentence = chapter.sentences.first(where: { $0.timestamps.contains { $0.id == spokenWord?.id }}) {
                store.dispatch(.storyAction(.updateCurrentSentence(sentence)))
            }
        }
        .onChange(of: currentSentence) { oldValue, newValue in
            let targetPage = sentenceIndex(newValue, in: chapter.sentences)
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
    
    private var playbackControls: some View {
        HStack(spacing: 16) {
            AudioButton()
            SpeechSpeedButton()
        }
    }
    
    @ViewBuilder
    private func paginationControls(totalPages: Int) -> some View {
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
