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
        if let story = store.state.storyState.currentStory {
            ScrollViewReader { proxy in
                scrollView(story: story, proxy: proxy)
                    .onChange(of: store.state.viewState.isAutoscrollEnabled) {
                        scrollToCurrentWord(spokenWord, proxy: proxy)
                    }
                    .onAppear {
                        opacity = 1
                        store.dispatch(.checkDeviceVolumeZero)
                        scrollToCurrentWord(spokenWord, proxy: proxy, isForced: true)
                    }
            }
        }
    }

    private func scrollToCurrentWord(_ word: WordTimeStampData?,
                                     proxy: ScrollViewProxy,
                                     isForced: Bool = false) {
        guard let word else { return }
        if isForced || store.state.viewState.isAutoscrollEnabled {
            withAnimation {
                proxy.scrollTo(word.id, anchor: .center)
            }
        }
    }

    @ViewBuilder
    func scrollView(story: Story, proxy: ScrollViewProxy) -> some View {
        ScrollView(.vertical) {
            ForEach(chapter.sentences, id: \.self) { sentence in
                flowLayout(sentence: sentence,
                           story: story,
                           proxy: proxy)
            }
            .padding(.trailing, 30)

            if !isTranslation {
                mainButton(story: story)
            }
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    store.dispatch(.updateAutoScrollEnabled(isEnabled: false))
                }
        )
    }

    private func flowLayout(sentence: Sentence,
                    story: Story,
                    proxy: ScrollViewProxy) -> some View
    {
        FlowLayout(spacing: 0, language: story.language) {
            ForEach(Array(sentence.timestamps.enumerated()), id: \.offset) { index, word in
                CharacterView(
                    word: word,
                    isHighlighted: word.id == spokenWord?.id,
                    isCurrentSentence: sentence.id == currentSentence?.id,
                    isTranslation: isTranslation
                )
                .id(word.id)
                .opacity(opacity)
                .animation(.easeInOut.delay(Double(index) * 0.02),
                           value: opacity)
            }
        }
        .onChange(of: spokenWord) {
            if sentence.timestamps.contains(where: { $0.id == spokenWord?.id }),
               currentSentence != sentence
            {
                if !isTranslation {
                    store.dispatch(.updateCurrentSentence(sentence))
                }
                scrollToCurrentWord(spokenWord, proxy: proxy)
            }
        }
        .frame(maxWidth: .infinity, alignment: story.language.alignment)
    }

    func mainButton(story: Story) -> some View {
        MainButton(title: LocalizedString.newChapter.uppercased()) {
            let doesNextChapterExist = story.chapters.count > story.currentChapterIndex + 1
            if doesNextChapterExist {
                store.dispatch(.updateAutoScrollEnabled(isEnabled: true))
                store.dispatch(.audioAction(.playSound(.goToNextChapter)))
                store.dispatch(.storyAction(.goToNextChapter))
            } else {
                store.dispatch(.snackbarAction(.showSnackBar(.writingChapter)))
                store.dispatch(.storyAction(.createChapter(.existingStory(story))))
            }
        }
        .disabled(store.state.viewState.isWritingChapter)
    }
}
