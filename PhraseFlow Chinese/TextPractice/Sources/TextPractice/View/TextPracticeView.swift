//
//  TextPracticeView.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import SwiftUI

struct TextPracticeView: View {
    @EnvironmentObject var store: TextPracticeStore

    var body: some View {
        VStack(spacing: 16) {
            AIStatementView()

            if (try? store.environment.isShowingDefinition()) == true || (try? store.environment.isShowingEnglish()) == true {
                SentenceDetailView()
            }

            ChapterHeaderView()

            SentenceView()
                .padding()
                .cardBackground()
            
        }
        .padding(10)
        .backgroundImage(type: .main)
    }
}
