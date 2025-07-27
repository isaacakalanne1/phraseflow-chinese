//
//  ContentView.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import Audio
import FTColor
import FTFont
import Localization
import Loading
import Navigation
import ReduxKit
import Settings
import SnackBar
import Story
import Study
import Subscription
import SwiftUI
import Translation
import UserLimit

// Temporary Redux types until infrastructure is properly integrated
struct FlowTaleState {
    // Commenting out missing state types for now
    // var audioState: AudioState
    var storyState: StoryState
    var settingsState: SettingsState
    // var studyState: StudyState
    // var translationState: TranslationState
    var subscriptionState: SubscriptionState
    var snackBarState: SnackBarState
    // var userLimitState: UserLimitState
    // var moderationState: ModerationState
    // var navigationState: NavigationState
    var viewState: ViewState
    
    init() {
        self.settingsState = SettingsState()
        // self.audioState = AudioState(speechSpeed: self.settingsState.speechSpeed)
        self.storyState = StoryState()
        // self.studyState = StudyState()
        // self.translationState = TranslationState()
        self.subscriptionState = SubscriptionState()
        self.snackBarState = SnackBarState()
        // self.userLimitState = UserLimitState()
        // self.moderationState = ModerationState()
        // self.navigationState = NavigationState()
        self.viewState = ViewState()
    }
    
    var deviceLanguage: Language? {
        settingsState.deviceLanguage
    }
}

struct ViewState {
    var isInitialisingApp: Bool = true
    var contentTab: Int = 0 // Temporary: reader tab
    var isShowingSubscriptionSheet: Bool = false
    var isShowingDailyLimitExplanation: Bool = false
    var isShowingFreeLimitExplanation: Bool = false
    var isDefining: Bool = false
    var isWritingChapter: Bool = false
    var definitionViewId: UUID = UUID()
    var isShowingCustomPromptAlert: Bool = false
}

enum FlowTaleAction {
    // Commenting out missing action types
    // case audioAction(AudioAction)
    case storyAction(StoryAction)
    case settingsAction(SettingsAction)
    // case studyAction(StudyAction)
    // case translationAction(TranslationAction)
    case subscriptionAction(SubscriptionAction)
    case snackBarAction(SnackbarAction)
    // case userLimitAction(UserLimitAction)
    // case moderationAction(ModerationAction)
    // case navigationAction(NavigationAction)
    // case loadingAction(LoadingAction)
    case viewAction(ViewAction)
    case loadAppSettings
    case playSound(SoundEffect)
}

enum ViewAction {
    case setInitializingApp(Bool)
    case setContentTab(Int) // Temporary: using Int instead of ContentTab
    case setSubscriptionSheetShowing(Bool)
    case setDailyLimitExplanationShowing(Bool)
    case setFreeLimitExplanationShowing(Bool)
    case setDefining(Bool)
    case setWritingChapter(Bool)
    case setDefinitionViewId(UUID)
    case setShowingCustomPromptAlert(Bool)
}

enum SoundEffect {
    case progressUpdate
}

protocol FlowTaleEnvironmentProtocol {
    var audioEnvironment: AudioEnvironmentProtocol { get }
    var storyEnvironment: StoryEnvironmentProtocol { get }
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    var translationEnvironment: TranslationEnvironmentProtocol { get }
    var subscriptionEnvironment: SubscriptionEnvironmentProtocol { get }
    var snackBarEnvironment: SnackBarEnvironmentProtocol { get }
    var userLimitEnvironment: UserLimitEnvironmentProtocol { get }
    var moderationEnvironment: ModerationEnvironmentProtocol { get }
    var navigationEnvironment: NavigationEnvironmentProtocol { get }
    var loadingEnvironment: LoadingEnvironmentProtocol { get }
}

typealias FlowTaleStore = Store<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>

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
        VStack {
            if !store.state.subscriptionState.isSubscribed {
                Text(LocalizedString.freeTrial)
                    .font(FTFont.flowTaleBodyXSmall())
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
                store.dispatch(.playSound(.progressUpdate))
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
                SnackbarView()
                    .transition(.push(from: .leading))
            }
            Spacer()
        }
        .animation(.easeInOut, value: store.state.snackBarState.isShowing)
    }

    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if store.state.audioState.audioPlayer.rate != 0 || store.state.studyState.audioPlayer.rate != 0 {
                if store.state.audioState.volume == .normal {
                    store.dispatch(.audioAction(.setMusicVolume(.quiet)))
                }
            } else {
                if store.state.audioState.volume == .quiet {
                    store.dispatch(.audioAction(.setMusicVolume(.normal)))
                }
            }

            // Update play time for audio state
            if store.state.audioState.isPlayingAudio {
                store.dispatch(.audioAction(.updatePlayTime))
            }

            if store.state.settingsState.isPlayingMusic,
               store.state.audioState.isNearEndOfTrack
            {
                let currentMusic = store.state.audioState.currentMusicType
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
