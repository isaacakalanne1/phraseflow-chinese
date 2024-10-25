//
//  ReaderView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ReaderView: View {
    let chapter: Chapter

    var body: some View {
        VStack(spacing: 10) {
            DefinitionView()
                .frame(height: 200)
            EnglishSentenceView()
                .frame(height: 100)
            ChapterView(chapter: chapter)
            Spacer()
            ActionButtonsView(chapter: chapter)
                .padding(.horizontal)
        }
    }
}
