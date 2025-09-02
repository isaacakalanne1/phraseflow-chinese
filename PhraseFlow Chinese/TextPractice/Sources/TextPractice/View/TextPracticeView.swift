//
//  TextPracticeView.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import SwiftUI
import TextGeneration

struct TextPracticeView: View {
    @EnvironmentObject var store: TextPracticeStore
    let chapter: Chapter

    var body: some View {
        VStack(spacing: 16) {
            AIStatementView()

            if (try? store.environment.isShowingDefinition()) == true || (try? store.environment.isShowingEnglish()) == true {
                SentenceDetailView()
            }

            ChapterHeaderView(chapter: chapter)

            SentenceView()
                .padding()
                .cardBackground()
            
        }
        .padding(10)
        .backgroundImage(type: .main)
    }
}
