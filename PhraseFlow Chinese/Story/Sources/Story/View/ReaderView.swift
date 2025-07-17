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
        VStack(spacing: 16) {
            AIStatementView()

            if store.state.settingsState.isShowingDefinition || store.state.settingsState.isShowingEnglish {
                SentenceDetailView()
            }

            storyHeaderSection

            storyContentSection
        }
        .padding(10)
        .backgroundImage(type: .main)
    }
    
    private var storyHeaderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let chapter = store.state.storyState.currentChapter {
                HStack(spacing: 12) {
                    StoryInfoView(chapter: chapter)
                    
                    Text(chapter.storyTitle)
                        .font(.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.primary)
                        .lineLimit(1)
                }
                
                Text(chapter.title)
                    .font(.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.primary.opacity(0.9))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var storyContentSection: some View {
        VStack {
            ListOfSentencesView()
                .padding()
        }
        .cardBackground()
    }
}
