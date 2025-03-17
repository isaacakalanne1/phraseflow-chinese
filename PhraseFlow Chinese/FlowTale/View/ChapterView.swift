//
//  ChapterView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ChapterView: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter

    @State var opacity: Double = 0

    var body: some View {
        if let story = store.state.storyState.currentStory {
            ScrollViewReader { proxy in
                // Use simultaneousGesture so the ScrollView can still scroll normally
                scrollView(story: story, proxy: proxy)
                // 2) Whenever the highlighted word changes, scroll if auto-scroll is still enabled
                .onChange(of: store.state.viewState.isAutoscrollEnabled) {
                    guard let newWord = store.state.storyState.currentSpokenWord else { return }
                    scrollToCurrentWord(newWord, proxy: proxy)
                }
                .onChange(of: store.state.storyState.currentSpokenWord) {
                    if let word = store.state.storyState.currentSpokenWord {
                        scrollToCurrentWord(word, proxy: proxy)
                    }
                }
            }
        }
    }

    private func scrollToCurrentWord(_ word: WordTimeStampData,
                                     proxy: ScrollViewProxy,
                                     isForced: Bool = false) {
        if isForced || store.state.viewState.isAutoscrollEnabled {
            withAnimation {
                // Scroll so the new word is at the bottom (use .center or .top if you prefer)
                proxy.scrollTo(word.id, anchor: .center)
            }
        }
    }

    @ViewBuilder
    func scrollView(story: Story, proxy: ScrollViewProxy) -> some View {
        ScrollView(.vertical) {
            ForEach(Array(chapter.sentences.enumerated()), id: \.offset) { sentenceIdx, sentence in
                let sentenceWords = sentence.wordTimestamps

                FlowLayout(spacing: 0, language: story.language) {
                    ForEach(Array(sentenceWords.enumerated()), id: \.offset) { index, word in
                        CharacterView(
                            isHighlighted: word == store.state.storyState.currentSpokenWord,
                            word: word
                        )
                        // Give each word a unique ID so we can scroll to it
                        .id(word.id)
                        .opacity(opacity)
                        .animation(.easeInOut.delay( Double(index) * 0.02 ),
                                   value: opacity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: story.language.alignment)
            }

            MainButton(title: LocalizedString.newChapter.uppercased()) {
                let doesNextChapterExist = story.chapters.count > story.currentChapterIndex + 1
                if doesNextChapterExist {
                    store.dispatch(.updateAutoScrollEnabled(isEnabled: true))
                    store.dispatch(.playSound(.goToNextChapter))
                } else {
                    store.dispatch(.snackBarAction(.showSnackBar(.writingChapter)))
                }
                let storyAction: StoryAction = doesNextChapterExist ? .goToNextChapter : .createChapter(.existingStory(story))
                store.dispatch(.storyAction(storyAction))
            }
            .disabled(store.state.storyState.isCreatingChapter)
        }
        .onAppear {
            opacity = 1
            store.dispatch(.checkDeviceVolumeZero)

            guard let newWord = store.state.storyState.currentSpokenWord else { return }
            scrollToCurrentWord(newWord, proxy: proxy, isForced: true)
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    store.dispatch(.updateAutoScrollEnabled(isEnabled: false))
                }
        )
    }
}
