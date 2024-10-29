//
//  ContentView.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FastChineseStore

    @FocusState var isTextFieldFocused
    @State private var showSettings = false
    @State private var showStoryListView = false

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
                    store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
                }
            case .failedToGenerateChapter:
                ErrorView(title: "Failed to generate chapter",
                          buttonTitle: "Retry") {
                    if let chapter = store.state.currentChapter {
                        store.dispatch(.generateChapter(previousChapter: chapter))
                    }
                }
            case .normal:
                if store.state.currentStory == nil {
                    Button("Create Story") {
                        store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
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
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded { value in
            let horizontalAmount = value.translation.width
            let verticalAmount = value.translation.height

            if horizontalAmount > 50 {
//                store.dispatch(.goToPreviousSentence)
            } else if horizontalAmount < -50 {
//                store.dispatch(.goToNextSentence)
            }
        })
    }

    func startTimer() {
        let increment: Double = 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + increment) {
            if store.state.audioPlayer?.isPlaying == true {
                store.dispatch(.incrementPlayTime(increment))
            }
            startTimer()
        }
    }
}

#Preview {
    ContentView()
}
