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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loading,
                     .normal:
                    ZStack(alignment: .topTrailing) {
                        mainContent()
                        if let chapter = store.state.storyState.currentChapter {
                            overlayView(chapter: chapter)
                        }
                    }
                }
            }
            if store.state.viewState.readerDisplayType != .loading,
               store.state.storyState.currentChapter != nil {
                Divider()
                    .padding(.horizontal, 10)
                ActionButtonsView()
                    .padding(.horizontal, 10)
            }
        }
        .onAppear {
            startTimer()
        }
        .sheet(isPresented: isShowingSubscriptionView) {
            SubscriptionView()
                .presentationDragIndicator(.hidden)
                .presentationDetents([.fraction(0.55)])
        }
        .onChange(of: store.state.viewState.loadingState) { oldValue, newValue in
            if newValue != .complete,
               newValue != .writing {
                store.dispatch(.playSound(.progressUpdate))
            }
        }
        .background(FlowTaleColor.background)
        .tint(FlowTaleColor.accent)
    }

    // MARK: - Main Content
    @ViewBuilder
    private func mainContent() -> some View {
        switch store.state.viewState.contentTab {
        case .reader:
            if store.state.viewState.readerDisplayType == .loading {
                LoadingView()
            } else if let _ = store.state.storyState.currentStory {
                if let chapter = store.state.storyState.currentChapter {
                    ReaderView(chapter: chapter)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // If no currentStory or no chapters, show Onboarding
                // (This is the scenario where we haven't loaded
                // or don't have any stories yet.)
                NavigationStack {
                    LanguageOnboardingView()
                }
            }

        case .storyList:
            NavigationStack {
                StoryListView()
            }

        case .study:
            NavigationStack {
                StudyView()
            }

        case .progress:
            NavigationStack {
                DefinitionsProgressSheetView()
            }

        case .subscribe:
            NavigationStack {
                SubscriptionView()
            }

        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }

    // MARK: - Overlay
    @ViewBuilder
    private func overlayView(chapter: Chapter) -> some View {
        VStack(alignment: .trailing) {
            if store.state.snackBarState.isShowing {
                SnackBar()
                    .transition(.move(edge: .leading))
            }
            Spacer()
            if store.state.viewState.contentTab == .reader {
                audioButton(chapter: chapter)
                    .padding(.trailing)
            }
        }
        .animation(.easeInOut, value: store.state.snackBarState.isShowing)
    }


    // MARK: - Timer
    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if store.state.audioState.isPlayingAudio {
                store.dispatch(.updatePlayTime)
            }
            startTimer()
        }
    }

    // MARK: - Audio Button
    @ViewBuilder
    func audioButton(chapter: Chapter) -> some View {
        let buttonSize: CGFloat = 50
        if store.state.viewState.readerDisplayType == .normal {
            if store.state.viewState.playButtonDisplayType == .loading {
                Button {} label: {
                    SystemImageView(.ellipsis, size: buttonSize)
                }
                .disabled(true)
            } else if store.state.settingsState.voice != chapter.audioVoice ||
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
                        let timestamps = chapter.audio.timestamps
                        let currentSpokenWord = store.state.currentSpokenWord ?? timestamps.first
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
