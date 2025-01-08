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

        let settingsView = SettingsView()
        let storyListView = StoryListView()

        ZStack(alignment: .topTrailing) {
            Group {
                switch store.state.viewState.readerDisplayType {
                case .initialising:
                    ProgressView()
                        .tint(FlowTaleColor.accent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loading:
                    LoadingView()
                case .normal:
                    if let chapter = store.state.storyState.currentChapter {
                        ReaderView(chapter: chapter)
                            .sheet(isPresented: isShowingSettingsScreen) {
                                settingsView
                            }
                            .onAppear {
                                store.dispatch(.showSnackBar(.chapterReady))
                            }
                    } else {
                        CreateStorySettingsView()
                    }
                }
            }
            if let chapter = store.state.storyState.currentChapter {
                overlayView(chapter: chapter)
            }
        }
        .onAppear {
            startTimer()
        }
        .sheet(isPresented: isShowingStoryListView) {
            NavigationStack {
                storyListView
            }
            .tint(FlowTaleColor.accent)
        }
        .sheet(isPresented: isShowingStudyView) {
            StudyView()
        }
        .sheet(isPresented: isShowingDefinitionsChartView) {
            NavigationStack {
                DefinitionsProgressSheetView()
            }
            .tint(FlowTaleColor.accent)
        }
        .sheet(isPresented: isShowingSubscriptionView) {
            SubscriptionView()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction(0.55)])
        }
        .background(FlowTaleColor.background)
    }

    @ViewBuilder
    private func overlayView(chapter: Chapter) -> some View {
        VStack(alignment: .trailing) {
            if store.state.snackBarState.isShowing {
                SnackBar()
                    .transition(.move(edge: .leading))
            }
            Spacer()
            audioButton(chapter: chapter)
                .padding(.trailing)
            Spacer()
                .frame(height: 60)
        }
        .animation(.easeInOut, value: store.state.snackBarState.isShowing)
    }


    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            if store.state.audioState.isPlayingAudio {
                store.dispatch(.updatePlayTime)
            }

            startTimer()
        }
    }

    @ViewBuilder
    func audioButton(chapter: Chapter) -> some View {
        let buttonSize: CGFloat = 50
        if store.state.viewState.readerDisplayType == .normal {
            if store.state.viewState.playButtonDisplayType == .loading {
                Button {

                } label: {
                    SystemImageView(.ellipsis, size: buttonSize)
                }
                .disabled(true)
            } else if chapter.audioData == nil ||
                        store.state.settingsState.voice != chapter.audioVoice ||
                        store.state.settingsState.speechSpeed != chapter.audioSpeed {
                Button {
                    if let story = store.state.storyState.currentStory {
                        store.dispatch(.synthesizeAudio(chapter,
                                                        story: story,
                                                        voice: store.state.settingsState.voice,
                                                        isForced: false))
                    }
                } label: {
                    SystemImageView(.arrowDown, size: buttonSize)
                }
            } else {
                if store.state.audioState.isPlayingAudio == true {
                    Button {
                        store.dispatch(.pauseAudio)
                    } label: {
                        SystemImageView(.pause, size: buttonSize)
                    }
                } else {
                    Button {
                        let timestampData = store.state.storyState.currentChapter?.timestampData
                        let currentSpokenWord = store.state.currentSpokenWord ?? timestampData?.first
                        store.dispatch(.playAudio(time: currentSpokenWord?.time))
                        store.dispatch(.updateAutoScrollEnabled(isEnabled: true))
                    } label: {
                        SystemImageView(.play, size: buttonSize)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
