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

    var body: some View {
        VStack(spacing: 16) {
            AIStatementView()

            SentenceDetailView()

            ChapterHeaderView()

            SentenceView()
                .padding()
                .cardBackground()
            
        }
        .padding(10)
        .backgroundImage(type: .main)
    }
}
