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
                store.dispatch(.setSubscriptionSheetShowing(newValue, .manualOpen))
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
        .preferredColorScheme(store.state.settingsState.appColorScheme?.colorScheme)
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
            if store.state.viewState.readerDisplayType == .loading {
                LoadingView()
            } else if let _ = store.state.storyState.currentStory {
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
                // If no currentStory or no chapters, show Onboarding
                // (This is the scenario where we haven't loaded
                // or don't have any stories yet.)
                NavigationStack {
                    LanguageOnboardingView()
                }
            }

        case .create:
            NavigationStack {
                CreateStorySettingsView()
                    .navigationDestination(
                        isPresented: isShowingDailyLimitExplanationScreen
                    ) {
                        DailyLimitExplanationView()
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

    // MARK: - Overlay
    @ViewBuilder
    private func overlayView(chapter: Chapter) -> some View {
        VStack(alignment: .trailing) {
            if store.state.snackBarState.isShowing {
                SnackBar()
                    .transition(.move(edge: .leading))
            }
            Spacer()
        }
        .animation(.easeInOut, value: store.state.snackBarState.isShowing)
    }


    // MARK: - Timer
    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if store.state.audioState.audioPlayer.rate != 0 {
                if store.state.musicAudioState.volume == .normal {
                    store.dispatch(.setMusicVolume(.quiet))
                }
            } else {
                if store.state.musicAudioState.volume == .quiet {
                    store.dispatch(.setMusicVolume(.normal))
                }
            }
            if store.state.audioState.isPlayingAudio {
                store.dispatch(.updatePlayTime)
            }
            startTimer()
        }
    }
}

enum MusicVolume {
    case normal, quiet

    var float: Float {
        switch self {
        case .normal:
            0.6
        case .quiet:
            0.25
        }
    }
}

#Preview {
    ContentView()
}
