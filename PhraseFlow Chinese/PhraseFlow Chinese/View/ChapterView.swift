//
//  ChapterView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ChapterView: View {
    @EnvironmentObject var store: FastChineseStore
    let chapter: Chapter

    var body: some View {
        ScrollView(.vertical) {
            ForEach(Array(chapter.sentences.enumerated()), id: \.element) { (sentenceIndex, sentence) in
                let columns = Array(repeating: GridItem(.flexible(minimum: 30, maximum: 50), spacing: 0), count: 10)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 30, maximum: 50), spacing: 0),
                                         count: 10),
                          spacing: 0) {
                    ForEach(Array(sentence.mandarin.enumerated()), id: \.offset) { index, element in
                        CharacterView(index: index)
                    }
                }
            }
        }
    }
}
