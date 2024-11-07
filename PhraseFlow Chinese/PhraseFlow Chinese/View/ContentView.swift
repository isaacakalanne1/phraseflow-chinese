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

        let isShowingCreateStoryScreen: Binding<Bool> = .init {
            store.state.isShowingCreateStoryScreen
        } set: { newValue in
            store.dispatch(.updateShowingCreateStoryScreen(isShowing: newValue))
        }

        let isShowingSettingsScreen: Binding<Bool> = .init {
            store.state.isShowingSettingsScreen
        } set: { newValue in
            store.dispatch(.updateShowingSettings(isShowing: newValue))
        }

        let isShowingStoryListView: Binding<Bool> = .init {
            store.state.isShowingStoryListView
        } set: { newValue in
            store.dispatch(.updateShowingStoryListView(isShowing: newValue))
        }

        VStack(spacing: 10) {
            switch store.state.viewState {
            case .loading:
                Text("Writing new chapter...")
                    .font(.body)
            case .failedToGenerateStory:
                ErrorView(title: "Failed to generate story",
                          buttonTitle: "Retry") {
                    let genres = Array(Genre.allCases.shuffled().prefix(3))
                    store.dispatch(.generateNewStory(genres: genres))
                }
            case .failedToGenerateChapter:
                ErrorView(title: "Failed to generate chapter",
                          buttonTitle: "Retry") {
                    if let story = store.state.currentStory {
                        store.dispatch(.generateChapter(story: story))
                    }
                }
            case .normal,
                    .defining:
                if store.state.currentStory == nil {
                    Button("Create Story") {
                        let genres = Array(Genre.allCases.shuffled().prefix(3))
                        store.dispatch(.generateNewStory(genres: genres))
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else if let chapter = store.state.currentChapter {
                    ReaderView(chapter: chapter)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .background(Color.white)
        .padding(10)
        .sheet(isPresented: isShowingSettingsScreen) {
            SettingsView()
        }
        .sheet(isPresented: isShowingCreateStoryScreen) {
            CreateStoryView()
        }
        .sheet(isPresented: isShowingStoryListView) {
            StoryListView()
        }
    }

    func startTimer() {
        let increment: Double = 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + increment) {

            if store.state.isPlayingAudio {
                store.dispatch(.updatePlayTime)
            }

            startTimer()
        }
    }
}

#Preview {
    ContentView()
}
