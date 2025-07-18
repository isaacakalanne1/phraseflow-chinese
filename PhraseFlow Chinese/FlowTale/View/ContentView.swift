//
//  ContentView.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import FTColor
import FTFont
import Localization
import Navigation
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        let isShowingSubscriptionView: Binding<Bool> = .init {
            store.state.viewState.isShowingSubscriptionSheet
        } set: { newValue in
            if !newValue {
                store.dispatch(.subscriptionAction(.setSubscriptionSheetShowing(newValue)))
            }
        }
        MainContentView()

        VStack {
            if !store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.freeTrial)
                    .font(.flowTaleBodyXSmall())
                    .foregroundStyle(FTColor.primary)
            }
            Group {
                if store.state.viewState.isInitialisingApp {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    mainContent()
                }
            }
            if !store.state.storyState.allStories.isEmpty {
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
        .onChange(of: store.state.viewState.loadingState) { _, newValue in
            if newValue != .complete,
               newValue != .writing {
                store.dispatch(.audioAction(.playSound(.progressUpdate)))
            }
        }
        .background(FTColor.background)
        .tint(FTColor.accent)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func mainContent() -> some View {
        let isShowingDailyLimitExplanationScreen: Binding<Bool> = .init {
            store.state.viewState.isShowingDailyLimitExplanation
        } set: { newValue in
            store.dispatch(.userLimitAction(.showDailyLimitExplanationScreen(isShowing: newValue)))
        }

        let isShowingFreeLimitExplanationScreen: Binding<Bool> = .init {
            store.state.viewState.isShowingFreeLimitExplanation
        } set: { newValue in
            store.dispatch(.userLimitAction(.showFreeLimitExplanationScreen(isShowing: newValue)))
        }

        VStack(spacing: 0) {
            LoadingProgressBar()
            
            ZStack(alignment: .topTrailing) {
                switch store.state.viewState.contentTab {
                case .reader:
                    if store.state.storyState.allStories.isEmpty {
                        NavigationStack {
                            LanguageOnboardingView()
                        }
                    } else if let chapter = store.state.storyState.currentChapter {
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

                case .translate:
                    NavigationStack {
                        TranslationView()
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
                snackbarView()
            }
        }
    }

    @ViewBuilder
    private func snackbarView() -> some View {
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
                    store.dispatch(.audioAction(.setMusicVolume(.quiet)))
                }
            } else {
                if store.state.musicAudioState.volume == .quiet {
                    store.dispatch(.audioAction(.setMusicVolume(.normal)))
                }
            }

            // Update play time for audio state
            if store.state.audioState.isPlayingAudio {
                store.dispatch(.audioAction(.updatePlayTime))
            }

            if store.state.settingsState.isPlayingMusic,
               store.state.musicAudioState.isNearEndOfTrack
            {
                let currentMusic = store.state.musicAudioState.currentMusicType
                let nextMusic = MusicType.next(after: currentMusic)
                store.dispatch(.audioAction(.playMusic(nextMusic)))
            }

            startTimer()
        }
    }
}

#Preview {
    ContentView()
}
