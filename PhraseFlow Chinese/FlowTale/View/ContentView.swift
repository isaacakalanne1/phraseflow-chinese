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
            if !newValue {
                store.dispatch(.setSubscriptionSheetShowing(newValue))
            }
        }

        VStack {
            if !store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.freeTrial)
                    .font(.system(size: 11))
                    .foregroundStyle(FlowTaleColor.primary)
            }
            Group {
                switch store.state.viewState.readerDisplayType {
                case .initialising:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .normal:
                    ZStack(alignment: .topTrailing) {
                        mainContent()
                        overlayView()
                    }
                }
            }
            if !store.state.storyState.savedStories.isEmpty {
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
                .presentationDetents([.fraction(0.8)])
        }
        .onChange(of: store.state.viewState.loadingState) { oldValue, newValue in
            if newValue != .complete,
               newValue != .writing {
                store.dispatch(.playSound(.progressUpdate))
            }
        }
        .background(FlowTaleColor.background)
        .tint(FlowTaleColor.accent)
        .preferredColorScheme(.dark)
    }

    // MARK: - Main Content
    @ViewBuilder
    private func mainContent() -> some View {

        let isShowingDailyLimitExplanationScreen: Binding<Bool> = .init {
            store.state.viewState.isShowingDailyLimitExplanation
        } set: { newValue in
            store.dispatch(.showDailyLimitExplanationScreen(isShowing: newValue))
        }

        let isShowingFreeLimitExplanationScreen: Binding<Bool> = .init {
            store.state.viewState.isShowingFreeLimitExplanation
        } set: { newValue in
            store.dispatch(.showFreeLimitExplanationScreen(isShowing: newValue))
        }

        switch store.state.viewState.contentTab {
        case .reader:
            if let _ = store.state.storyState.currentStory {
                if let chapter = store.state.storyState.currentChapter {
                    NavigationStack {
                        ReaderView(chapter: chapter)
                            .navigationDestination(
                                isPresented: isShowingDailyLimitExplanationScreen
                            ) {
                                DailyLimitExplanationView()
                            }
                            .navigationDestination(
                                isPresented: isShowingFreeLimitExplanationScreen
                            ) {
                                FreeLimitExplanationView()
                            }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                NavigationStack {
                    LanguageOnboardingView()
                }
            }

        case .storyList:
            NavigationStack {
                StoryListView()
                    .navigationDestination(
                        isPresented: isShowingDailyLimitExplanationScreen
                    ) {
                        DailyLimitExplanationView()
                    }
            }

        case .progress:
            NavigationStack {
                DefinitionsProgressSheetView()
            }

        case .subscribe:
            NavigationStack {
                SubscriptionView()
                    .navigationDestination(
                        isPresented: isShowingFreeLimitExplanationScreen
                    ) {
                        FreeLimitExplanationView()
                    }
            }

        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }

    @ViewBuilder
    private func overlayView() -> some View {
        VStack(alignment: .trailing) {
            if store.state.snackBarState.isShowing {
                SnackBar()
                    .transition(.push(from: .leading))
            }
            Spacer()
        }
        .animation(.easeInOut, value: store.state.snackBarState.isShowing)
    }

    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if store.state.audioState.audioPlayer.rate != 0 || store.state.studyState.audioPlayer.rate != 0 {
                if store.state.musicAudioState.volume == .normal {
                    store.dispatch(.setMusicVolume(.quiet))
                }
            } else {
                if store.state.musicAudioState.volume == .quiet {
                    store.dispatch(.setMusicVolume(.normal))
                }
            }
            
            // Update play time for audio state
            if store.state.audioState.isPlayingAudio {
                store.dispatch(.updatePlayTime)
            }
            
            if store.state.settingsState.isPlayingMusic,
               store.state.musicAudioState.isNearEndOfTrack {
                let currentMusic = store.state.musicAudioState.currentMusicType
                let nextMusic = MusicType.next(after: currentMusic)
                store.dispatch(.playMusic(nextMusic))
            }

            startTimer()
        }
    }
}

#Preview {
    ContentView()
}
