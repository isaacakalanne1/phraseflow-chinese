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
                scrollView(story: story, proxy: proxy)
                .onChange(of: store.state.viewState.isAutoscrollEnabled) {
                    guard let newWord = store.state.storyState.currentSpokenWord else { return }
                    scrollToCurrentWord(newWord, proxy: proxy)
                }
                .onChange(of: store.state.storyState.currentSentence, { oldValue, newValue in
                    if let word = store.state.storyState.currentSpokenWord {
                        scrollToCurrentWord(word, proxy: proxy)
                    }
                })
            }
        }
    }

    private func scrollToCurrentWord(_ word: WordTimeStampData,
                                     proxy: ScrollViewProxy,
                                     isForced: Bool = false) {
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

                FlowLayout(spacing: 0, language: story.language) {
                    ForEach(Array(sentence.timestamps.enumerated()), id: \.offset) { index, word in
                        CharacterView(
                            isHighlighted: word == store.state.storyState.currentSpokenWord,
                            isCurrentSentence: sentence == store.state.storyState.currentSentence,
                            word: word
                        )
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
                    store.dispatch(.goToNextChapter)
                } else {
                    store.dispatch(.showSnackBar(.writingChapter))
                    store.dispatch(.createChapter(.existingStory(story)))
                }
            }
            .disabled(store.state.viewState.isWritingChapter)
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
