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

    var body: some View {
        if let story = store.state.storyState.currentStory {
            ScrollViewReader { proxy in
                // Use simultaneousGesture so the ScrollView can still scroll normally
                scrollView(story: story)
                // 2) Whenever the highlighted word changes, scroll if auto-scroll is still enabled
                .onChange(of: store.state.viewState.isAutoscrollEnabled) {
                    guard let newWord = store.state.currentSpokenWord else { return }
                    scrollToCurrentWord(newWord, proxy: proxy)
                }
                .onChange(of: store.state.currentSpokenWord) { newWord in
                    guard let newWord = newWord else { return }
                    scrollToCurrentWord(newWord, proxy: proxy)
                }
                .onAppear {
                    guard let newWord = store.state.currentSpokenWord else { return }
                    scrollToCurrentWord(newWord, proxy: proxy, isForced: true)
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
    func scrollView(story: Story) -> some View {
        ScrollView(.vertical) {
            ForEach(0...(chapter.audio.timestamps.last?.sentenceIndex ?? 0),
                    id: \.self) { sentenceIdx in
                let sentenceWords = chapter.audio.timestamps.filter({ $0.sentenceIndex == sentenceIdx })

                FlowLayout(spacing: 0, language: story.language) {
                    ForEach(Array(sentenceWords.enumerated()), id: \.offset) { index, word in
                        CharacterView(
                            isHighlighted: word == store.state.currentSpokenWord,
                            word: word
                        )
                        // Give each word a unique ID so we can scroll to it
                        .id(word.id)
                    }
                }
                .frame(maxWidth: .infinity, alignment: story.language.alignment)
            }

            if story.chapters.count >= 20 {
                Button(LocalizedString.nextChapter) {
                    let doesNextChapterExist = story.chapters.count > story.currentChapterIndex + 1
                    if doesNextChapterExist {
                        store.dispatch(.updateAutoScrollEnabled(isEnabled: true))
                        store.dispatch(.playSound(.goToNextChapter))
                        store.dispatch(.goToNextChapter)
                    } else {
                        store.dispatch(.playSound(.createNextChapter))
                        store.dispatch(.createChapter(.existingStory(story)))
                    }
                }
                .padding()
                .background(FlowTaleColor.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
//                Button("Create Sequel") { // TODO: Localize
//                    store.dispatch(.playSound(.createNextChapter))
//                    let sequelId = UUID()
//                    var prequelStory = story
//                    prequelStory.sequelId = sequelId
//                    prequelStory.id = UUID()
//                    store.dispatch(.createChapter(.sequel(story,
//                                                          newId: sequelId)))
//                    store.dispatch(.deleteStory(story))
//                    store.dispatch(.saveStoryAndSettings(prequelStory))
//                }
//                .padding()
//                .background(FlowTaleColor.accent)
//                .foregroundColor(.white)
//                .cornerRadius(10)
            }
        }
        .id(store.state.viewState.chapterViewId)

        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    store.dispatch(.updateAutoScrollEnabled(isEnabled: false))
                }
        )
    }
}
