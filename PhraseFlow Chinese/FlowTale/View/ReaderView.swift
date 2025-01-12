//
//  ReaderView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter

    var body: some View {
        VStack(spacing: 10) {
            AIStatementView()
            if store.state.settingsState.isShowingDefinition {
                DefinitionView()
                    .frame(height: 150)
            }
            if store.state.settingsState.isShowingEnglish {
                EnglishSentenceView()
                    .frame(height: 120)
            }
            ChapterHeaderView(chapter: chapter)
            ChapterView(chapter: chapter)
        }
        .padding(10)
    }
}
