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

        VStack {
            Group {
                switch store.state.viewState.readerDisplayType {
                case .initialising:
                    ProgressView()
                        .tint(FlowTaleColor.accent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loading:
                    LoadingView()
                case .normal:
                    mainContent()
                }
            }
            ActionButtonsView()
                .padding(.horizontal, 10)
        }
        .onAppear {
            startTimer()
        }
        .sheet(isPresented: isShowingSubscriptionView) {
            SubscriptionView()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction(0.55)])
        }
        .background(FlowTaleColor.background)
    }

    @ViewBuilder
    private func mainContent() -> some View {
        switch store.state.viewState.contentTab {
        case .reader:
            if let chapter = store.state.storyState.currentChapter {
                ZStack(alignment: .topTrailing) {
                    ReaderView(chapter: chapter)
                    if let chapter = store.state.storyState.currentChapter {
                        overlayView(chapter: chapter)
                    }
                }
            } else {
                CreateStorySettingsView()
            }
        case .storyList:
            StoryListView()
        case .study:
            StudyView()
        case .progress:
            DefinitionsProgressSheetView()
        case .settings:
            SettingsView()
        }
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
