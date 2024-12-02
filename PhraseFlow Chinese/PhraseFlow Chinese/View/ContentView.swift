//
//  ContentView.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FastChineseStore

    var body: some View {

        let isShowingSettingsScreen: Binding<Bool> = .init {
            store.state.viewState.isShowingSettingsScreen
        } set: { newValue in
            store.dispatch(.updateShowingSettings(isShowing: newValue))
        }

        let isShowingStoryListView: Binding<Bool> = .init {
            store.state.viewState.isShowingStoryListView
        } set: { newValue in
            store.dispatch(.updateShowingStoryListView(isShowing: newValue))
        }

        VStack(spacing: 10) {
            switch store.state.viewState.readerDisplayType {
            case .loading:
                Text(LocalizedString.writingNewChapter)
                    .font(.body)
            case .fetching:
                EmptyView()
            case .failedToGenerateStory:
                ErrorView(title: LocalizedString.failedToWriteStory,
                          buttonTitle: LocalizedString.retry) {
                    store.dispatch(.continueStory(story: nil))
                }
            case .failedToGenerateChapter:
                ErrorView(title: LocalizedString.failedToWriteChapter,
                          buttonTitle: LocalizedString.retry) {
                    if let story = store.state.storyState.currentStory {
                        store.dispatch(.continueStory(story: story))
                    }
                }
            case .normal,
                    .defining:
                if store.state.storyState.currentStory == nil {
                    CreateStorySettingsView()
                } else if let chapter = store.state.storyState.currentChapter {
                    ReaderView(chapter: chapter)
                        .padding(10)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .background(Color.white)
        .sheet(isPresented: isShowingSettingsScreen) {
            SettingsView()
        }
        .sheet(isPresented: isShowingStoryListView) {
            StoryListView()
        }
    }

    func startTimer() {
        let increment: Double = 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + increment) {

            if store.state.audioState.isPlayingAudio {
                store.dispatch(.updatePlayTime)
            }

            startTimer()
        }
    }
}

#Preview {
    ContentView()
}
