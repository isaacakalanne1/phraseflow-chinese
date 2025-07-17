//
//  ChapterListView.swift
//  FlowTale
//
//  Created by iakalann on 18/10/2024.
//

import SwiftUI

struct ChapterListView: View {
    @EnvironmentObject var store: FlowTaleStore
    let storyId: UUID

    private var firstChapter: Chapter? {
        store.state.storyState.firstChapter(for: storyId)
    }
    
    private var allChaptersForStory: [Chapter] {
        store.state.storyState.storyChapters[storyId] ?? []
    }

    var body: some View {
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
                                    .fill(.ftSecondary.opacity(0.1))
                                
                                Image(systemName: "book.closed.fill")
                                    .font(.flowTaleBodyXLarge())
                                    .foregroundColor(.ftSecondary.opacity(0.5))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 200)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(firstChapter.storyTitle)
                            .font(.flowTaleSecondaryHeader())
                            .foregroundColor(.ftPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            DifficultyView(difficulty: firstChapter.difficulty, isSelected: true)
                            Text(firstChapter.difficulty.title)
                                .font(.flowTaleSecondaryHeader())
                                .foregroundColor(.ftSecondary)
                        }
                    }
                    
                    Text(firstChapter.chapterSummary)
                        .font(.flowTaleSecondaryHeader())
                        .foregroundColor(.ftPrimary.opacity(0.8))
                        .lineLimit(3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        HStack {
                            Text(LocalizedString.chapters)
                                .font(.flowTaleSecondaryHeader())
                                .foregroundColor(.ftSecondary)
                            
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
                                .font(.flowTaleBodyXSmall())
                        },
                        title: LocalizedString.newChapter
                    ) {
                        store.dispatch(.storyAction(.createChapter(.existingStory(storyId))))
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
                                    .ftBackground.opacity(0),
                                    .ftBackground
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
            .background(.ftBackground)
            .scrollContentBackground(.hidden)
            .onAppear {
                store.dispatch(.audioAction(.playSound(.openStory)))
            }
        } else {
            Text(LocalizedString.chapterListStoryNotFound)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ftBackground)
        }
    }

    private var emptyChaptersView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.flowTaleBodyXLarge())
                .foregroundColor(FTColor.accent.opacity(0.6))
                .padding(.top, 20)
            
            Text(LocalizedString.noChaptersYet)
                .font(.flowTaleSecondaryHeader())
                .foregroundColor(.ftPrimary)
            
            Text(LocalizedString.createYourFirstChapter)
                .font(.flowTaleSecondaryHeader())
                .foregroundColor(.ftSecondary)
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
                store.dispatch(.audioAction(.playSound(.openChapter)))
                let chapterIndex = allChaptersForStory.count - 1 - index
                store.dispatch(.navigationAction(.selectChapter(storyId, chapterIndex: chapterIndex)))
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(FTColor.accent.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text("\(allChaptersForStory.count - index)")
                        .font(.flowTaleBodyXSmall())
                        .foregroundColor(FTColor.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chapter.title)
                        .font(.flowTaleBodyXSmall())
                        .foregroundColor(.ftPrimary)
                        .lineLimit(1)

                    let snippetText = chapter.sentences.prefix(1).map { $0.original }.first ?? ""
                    if !snippetText.isEmpty {
                        Text(snippetText)
                            .font(.flowTaleBodyXSmall())
                            .foregroundColor(.ftSecondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.ftSecondary)
                    .font(.flowTaleBodyXSmall())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ftBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
