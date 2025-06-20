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

    private let chapter: Chapter
    private let isTranslation: Bool

    var spokenWord: WordTimeStampData? {
        isTranslation ? store.state.translationState.currentSpokenWord : store.state.storyState.currentSpokenWord
    }

    var currentSentence: Sentence? {
        isTranslation ? store.state.translationState.currentSentence : store.state.storyState.currentSentence
    }

    init(chapter: Chapter,
         isTranslation: Bool = false) {
        self.chapter = chapter
        self.isTranslation = isTranslation
    }

    var body: some View {
        ScrollViewReader { proxy in
            if let chapter = store.state.storyState.currentChapter {
                scrollView(chapter: chapter, proxy: proxy)
            }
        }
    }

    @ViewBuilder
    func scrollView(chapter: Chapter, proxy: ScrollViewProxy) -> some View {
        ScrollView(.vertical) {
            ForEach(chapter.sentences, id: \.self) { sentence in
                flowLayout(sentence: sentence,
                           language: chapter.language,
                           proxy: proxy)
            }
            .padding(.trailing, 30)

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
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    store.dispatch(.storyAction(.updateAutoScrollEnabled(isEnabled: false)))
                }
        )
        .onChange(of: store.state.viewState.isAutoscrollEnabled) { oldValue, newValue in
            guard newValue else { return }
            scrollToCurrentWord(spokenWord, proxy: proxy)
        }
        .onAppear {
            opacity = 1
            store.dispatch(.snackbarAction(.checkDeviceVolumeZero))
            scrollToCurrentWord(spokenWord, proxy: proxy)
        }
    }

    private func flowLayout(sentence: Sentence,
                            language: Language,
                            proxy: ScrollViewProxy) -> some View {
        FlowLayout(spacing: 0, language: language) {
            ForEach(Array(sentence.timestamps.enumerated()), id: \.offset) { index, word in
                CharacterView(word: word, sentence: sentence, isTranslation: isTranslation)
                    .id(word.id)
                    .opacity(opacity)
                    .animation(.easeInOut.delay(Double(index) * 0.02), value: opacity)
            }
        }
        .onChange(of: spokenWord) { oldValue, newValue in
            if sentence.timestamps.contains(where: { $0.id == spokenWord?.id }),
               currentSentence != sentence {
                if !isTranslation {
                    store.dispatch(.storyAction(.updateCurrentSentence(sentence)))
                }
                guard let newValue else { return }
                scrollToCurrentWord(newValue, proxy: proxy)
            }
        }
        .frame(maxWidth: .infinity, alignment: language.alignment)
    }

    private func scrollToCurrentWord(_ word: WordTimeStampData?,
                                     proxy: ScrollViewProxy) {
        guard let word else { return }
        withAnimation {
            proxy.scrollTo(word.id, anchor: .center)
        }
    }
}
