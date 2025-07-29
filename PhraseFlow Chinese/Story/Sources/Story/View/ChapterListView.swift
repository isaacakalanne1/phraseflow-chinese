//
//  ChapterListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI
import FTFont
import FTColor
import FTStyleKit
import TextGeneration
import Localization
import Audio

public struct ChapterListView: View {
    @EnvironmentObject var store: StoryStore
    let storyId: UUID
    @State private var selectedChapter: Chapter?
    
    public init(storyId: UUID) {
        self.storyId = storyId
    }

    private var firstChapter: Chapter? {
        store.state.firstChapter(for: storyId)
    }
    
    private var allChaptersForStory: [Chapter] {
        store.state.storyChapters[storyId] ?? []
    }

    public var body: some View {
        Group {
            if let firstChapter = firstChapter {
                VStack(spacing: 0) {
                    GeometryReader { proxy in
                        Group {
                            if let image = firstChapter.coverArt {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: proxy.size.width / 2)
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
                            } else {
                                ZStack {
                                    Rectangle()
                                        .fill(FTColor.secondary.opacity(0.1))
                                    
                                    Image(systemName: "book.closed.fill")
                                        .font(FTFont.flowTaleBodyXLarge())
                                        .foregroundColor(FTColor.secondary.opacity(0.5))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 200)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(firstChapter.storyTitle)
                                .font(FTFont.flowTaleSecondaryHeader())
                                .foregroundColor(FTColor.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                DifficultyView(difficulty: firstChapter.difficulty, isSelected: true)
                                Text(firstChapter.difficulty.title)
                                    .font(FTFont.flowTaleSecondaryHeader())
                                    .foregroundColor(FTColor.secondary)
                            }
                        }
                        
                        Text(firstChapter.chapterSummary)
                            .font(FTFont.flowTaleSecondaryHeader())
                            .foregroundColor(FTColor.primary.opacity(0.8))
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            HStack {
                                Text(LocalizedString.chapters)
                                    .font(FTFont.flowTaleSecondaryHeader())
                                    .foregroundColor(FTColor.secondary)
                                
                                Spacer()
                                
                                if store.state.viewState.loadingState != .complete {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            
                            if allChaptersForStory.isEmpty && store.state.viewState.loadingState == .complete {
                                emptyChaptersView
                            } else {
                                ForEach(Array(allChaptersForStory.reversed().enumerated()), id: \.offset) { index, chapter in
                                    chapterCard(for: chapter, at: index)
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    
                    VStack {
                        PrimaryButton(
                            icon: {
                                Image(systemName: "plus")
                                    .font(FTFont.flowTaleBodyXSmall())
                            },
                            title: LocalizedString.newChapter
                        ) {
                            store.dispatch(.createChapter(.existingStory(storyId)))
                        }
                        .disabled(store.state.viewState.isWritingChapter)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .shadow(color: FTColor.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .background(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        FTColor.background.opacity(0),
                                        FTColor.background
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 100)
                            .offset(y: -50)
                    )
                }
                .navigationTitle(LocalizedString.chooseChapter)
                .background(FTColor.background)
                .scrollContentBackground(.hidden)
                .onAppear {
                    store.environment.playSound(.openStory)
                }
                .navigationDestination(isPresented: Binding<Bool>(
                    get: { selectedChapter != nil },
                    set: { if !$0 { selectedChapter = nil } }
                )) {
                    if let chapter = selectedChapter {
                        ReaderView(chapter: chapter)
                            .environmentObject(store)
                    }
                }
            } else {
                Text(LocalizedString.chapterListStoryNotFound)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(FTColor.background)
            }
        }
    }

    private var emptyChaptersView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(FTFont.flowTaleBodyXLarge())
                .foregroundColor(FTColor.accent.opacity(0.6))
                .padding(.top, 20)
            
            Text(LocalizedString.noChaptersYet)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.primary)
            
            Text(LocalizedString.createYourFirstChapter)
                .font(FTFont.flowTaleSecondaryHeader())
                .foregroundColor(FTColor.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private func chapterCard(for chapter: Chapter, at index: Int) -> some View {
        Button {
            withAnimation(.easeInOut) {
                store.environment.playSound(.openChapter)
                selectedChapter = chapter
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(FTColor.accent.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text("\(allChaptersForStory.count - index)")
                        .font(FTFont.flowTaleBodyXSmall())
                        .foregroundColor(FTColor.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title)
                        .font(FTFont.flowTaleBodyXSmall())
                        .foregroundColor(FTColor.primary)
                        .lineLimit(1)

                    let snippetText = chapter.sentences.prefix(1).map { $0.original }.first ?? ""
                    if !snippetText.isEmpty {
                        Text(snippetText)
                            .font(FTFont.flowTaleBodyXSmall())
                            .foregroundColor(FTColor.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(FTColor.secondary)
                    .font(FTFont.flowTaleBodyXSmall())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FTColor.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
