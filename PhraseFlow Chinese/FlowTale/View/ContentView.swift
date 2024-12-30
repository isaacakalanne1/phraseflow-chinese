//
//  ContentView.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {

        let isShowingSubscriptionView: Binding<Bool> = .init {
            store.state.viewState.isShowingSubscriptionSheet
        } set: { newValue in
            store.dispatch(.setSubscriptionSheetShowing(newValue))
        }

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

        let isShowingStudyView: Binding<Bool> = .init {
            store.state.viewState.isShowingStudyView
        } set: { newValue in
            store.dispatch(.updateShowingStudyView(isShowing: newValue))
        }

        let isShowingDefinitionsChartView: Binding<Bool> = .init {
            store.state.viewState.isShowingDefinitionsChartView
        } set: { newValue in
            store.dispatch(.updateShowingDefinitionsChartView(isShowing: newValue))
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
                    store.dispatch(.continueStory(story: store.state.createNewStory()))
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
                    ZStack(alignment: .top) {
                        ReaderView(chapter: chapter)
                            .padding(10)
                        if store.state.snackBarState.isShowing {
                            SnackBar()
                        }
                    }
                } else {

                }
            }
        }
        .onAppear {
            startTimer()
        }
        .background(FlowTaleColor.background)
        .sheet(isPresented: isShowingSettingsScreen) {
            SettingsView()
        }
        .sheet(isPresented: isShowingStoryListView) {
            StoryListView()
        }
        .sheet(isPresented: isShowingStudyView) {
            StudyView()
        }
        .sheet(isPresented: isShowingDefinitionsChartView) {
            NavigationStack {
                DefinitionsProgressSheetView()
            }
        }
        .sheet(isPresented: isShowingSubscriptionView) {
            SubscriptionView()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction(0.5)])
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
