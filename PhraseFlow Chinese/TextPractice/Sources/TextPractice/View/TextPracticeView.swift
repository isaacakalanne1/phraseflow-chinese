//
//  TextPracticeView.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import FTColor
import FTStyleKit
import SwiftUI

struct TextPracticeView: View {
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
        .background(FTColor.background)
    }
}
