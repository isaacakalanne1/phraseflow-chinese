//
//  ReaderView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var store: FastChineseStore
    let chapter: Chapter

    var body: some View {
        let startCharacterIndex = store.state.currentSpokenWord?.textOffset ?? -1
        let (selectedSentenceIndex, selectedCharacterIndex) = getSentenceAndCharIndex(textOffset: startCharacterIndex) ?? (-1,-1)
        let chapterNumber = (store.state.currentStory?.currentChapterIndex ?? 0) + 1

        VStack(spacing: 10) {
            DefinitionView()
                .frame(height: 150)
            EnglishSentenceView()
                .frame(height: 90)
            HStack(spacing: 0) {
                Text(store.state.currentStory?.title ?? "")
                    .bold()
                Text(" ")
                    .fontWeight(.light)
                Text("Chapter \(chapterNumber)")
                    .fontWeight(.light)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
            .background {
                if store.state.isShowingEnglish {
                    Color.gray.opacity(0.3)
                        .clipShape(.rect(cornerRadius: 5))
                }
            }
            ChapterView(chapter: chapter,
                        currentSpokenWord: store.state.currentSpokenWord,
                        selectedSentenceIndex: selectedSentenceIndex,
                        selectedCharacterIndex: selectedCharacterIndex)
            Spacer()
            ActionButtonsView(chapter: chapter)
                .padding(.horizontal)
        }
    }

    func getSentenceAndCharIndex(textOffset: Int) -> (sentenceIndex: Int, characterIndex: Int)? {
        var totalCharacterIndex = 0

        for (sentenceIndex, sentence) in chapter.sentences.enumerated() {
            let mandarinCharacters = Array(sentence.mandarin)
            let sentenceLength = mandarinCharacters.count

            if totalCharacterIndex + sentenceLength > textOffset {
                let characterIndex = textOffset - totalCharacterIndex
                if sentenceIndex != store.state.sentenceIndex {
                    store.dispatch(.updateSentenceIndex(sentenceIndex))
                }
                return (sentenceIndex, characterIndex)
            } else {
                totalCharacterIndex += sentenceLength
            }
        }
        return nil
    }
}
