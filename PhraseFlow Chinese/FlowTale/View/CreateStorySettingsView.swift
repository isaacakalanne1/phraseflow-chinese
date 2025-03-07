//
//  CreateStorySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 22/11/2024.
//

import SwiftUI
import AVKit

struct CreateStorySettingsView: View {
    @EnvironmentObject var store: FlowTaleStore

    @State var isShowingLanguageSettings = false
    @State var isShowingDifficultySettings = false
    @State var isShowingPromptSettings = false
    @State var isShowingVoiceSettings = false
    @State var isShowingSpeedSettings = false

    var body: some View {

        let currentDifficulty = store.state.settingsState.difficulty
        let currentLanguage = store.state.settingsState.language
        let currentStorySetting = store.state.settingsState.storySetting
        let currentVoice = store.state.settingsState.voice
        
        // Story Prompt variables
        let promptImage: UIImage?
        let promptDisplayText: String
        let promptFallbackText: String
        
        switch currentStorySetting {
        case .random:
            promptImage = UIImage(named: "StoryPrompt-Random")
            promptDisplayText = LocalizedString.random
            promptFallbackText = "🎲"
        case .customPrompt(let prompt):
            promptImage = UIImage(named: "StoryPrompt-Custom")
            let firstLetter = prompt.prefix(1).capitalized
            let remainingLetters = prompt.dropFirst()
            promptDisplayText = firstLetter + remainingLetters
            promptFallbackText = "📝"
        }

        return VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        // Language Button
                        VStack(spacing: 2) {
                            ImageSelectionButton(
                                title: currentLanguage.displayName,
                                image: currentLanguage.thumbnail,
                                fallbackText: currentLanguage.flagEmoji,
                                isSelected: false,
                                action: {
                                    isShowingLanguageSettings = true
                                    store.dispatch(.playSound(.openStorySettings))
                                }
                            )
                        }
                        
                        // Difficulty Button
                        VStack(spacing: 2) {
                            ImageSelectionButton(
                                title: currentDifficulty.title,
                                image: currentDifficulty.thumbnail,
                                fallbackText: currentDifficulty.emoji,
                                isSelected: false,
                                action: {
                                    isShowingDifficultySettings = true
                                    store.dispatch(.playSound(.openStorySettings))
                                }
                            )
                        }
                        
                        // Story Prompt Button
                        VStack(spacing: 2) {
                            ImageSelectionButton(
                                title: promptDisplayText,
                                image: promptImage,
                                fallbackText: promptFallbackText,
                                isSelected: false,
                                useFullButtonText: promptDisplayText.count > 20,
                                action: {
                                    isShowingPromptSettings = true
                                    store.dispatch(.playSound(.openStorySettings))
                                }
                            )
                        }
                        
                        // Voice Button
                        VStack(spacing: 2) {
                            ImageSelectionButton(
                                title: currentVoice.title,
                                image: currentVoice.thumbnail,
                                fallbackText: currentVoice.gender.emoji,
                                isSelected: false,
                                action: {
                                    isShowingVoiceSettings = true
                                    store.dispatch(.playSound(.openStorySettings))
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxHeight: .infinity)

            CreateStoryButton()
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .bottom])
        }
        .background(backgroundView)
        .navigationTitle(LocalizedString.createStory)
        .navigationDestination(
            isPresented: $isShowingLanguageSettings
        ) {
            LanguageSettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingDifficultySettings
        ) {
            DifficultySettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingPromptSettings
        ) {
            StoryPromptSettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingVoiceSettings
        ) {
            VoiceSettingsView()
        }
        .navigationDestination(
            isPresented: $isShowingSpeedSettings
        ) {
            SpeechSpeedSettingsView()
        }
    }

    @ViewBuilder
    var backgroundView: some View {
        if let uiImage = UIImage(named: "CreateStoryBackground") {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay {
                    FlowTaleColor.background.opacity(0.9)
                }
        } else {
            FlowTaleColor.background
        }
    }
}

struct CreateStoryButton: View {
    @EnvironmentObject var store: FlowTaleStore
    @State private var player: AVPlayer?
    
    var body: some View {
        MainButton(title: LocalizedString.newStory.uppercased()) {
            store.dispatch(.playSound(.largeBoom))

            // Check if user has existing stories
            let hasExistingStories = !store.state.storyState.savedStories.isEmpty

            if hasExistingStories {
                // For existing users, show a snackbar with loading and stay on current view
                store.dispatch(.showSnackBar(.writingChapter))
                store.dispatch(.createChapter(.newStory))
            } else {
                // For new users, use the original flow with full screen loading
                store.dispatch(.selectTab(.reader, shouldPlaySound: false))
                store.dispatch(.createChapter(.newStory))
            }
        }
        // Disable button if currently writing a chapter
        .disabled(store.state.viewState.isWritingChapter)
    }
}

struct MainButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                // Video background
                if let url = Bundle.main.url(forResource: "ButtonBackground", withExtension: "mp4") {
                    let player = AVPlayer(url: url)
                    VideoBackgroundView(player: player)
                        .frame(height: 70)
                        .onAppear {
                            player.play()
                        }
                        .overlay {
                            FlowTaleColor.accent.opacity(0.6)
                        }
                        .cornerRadius(10)
                        .scaleEffect(x: -1, y: 1)
                }

                // Button content
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .foregroundColor(.white)
            }
        }
    }
}

struct VideoBackgroundView: UIViewControllerRepresentable {
    var player: AVPlayer
    
    class Coordinator: NSObject {
        var parent: VideoBackgroundView
        
        init(_ parent: VideoBackgroundView) {
            self.parent = parent
            super.init()
        }
        
        @objc func playerItemDidReachEnd(notification: Notification) {
            parent.player.seek(to: CMTime.zero)
            parent.player.play()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsVideoFrameAnalysis = false
        controller.player = player
        controller.showsPlaybackControls = false
        controller.requiresLinearPlayback = true
        controller.videoGravity = .resizeAspectFill
        controller.updatesNowPlayingInfoCenter = false
        
        // Configure player for looping
        player.actionAtItemEnd = .none
        
        // Add observer for video end to loop
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        // Apply horizontal flip transformation
        DispatchQueue.main.async {
            if let playerLayer = controller.view.layer.sublayers?.compactMap({ $0 as? AVPlayerLayer }).first {
                playerLayer.transform = CATransform3DMakeScale(-1, 1, 1)
            }
        }
        
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        // Ensure flip is applied if view is refreshed
        DispatchQueue.main.async {
            if let playerLayer = controller.view.layer.sublayers?.compactMap({ $0 as? AVPlayerLayer }).first {
                playerLayer.transform = CATransform3DMakeScale(-1, 1, 1)
            }
        }
    }
    
    static func dismantleUIViewController(_ controller: AVPlayerViewController, coordinator: Coordinator) {
        // Remove observer when view is destroyed
        NotificationCenter.default.removeObserver(
            coordinator,
            name: .AVPlayerItemDidPlayToEndTime,
            object: controller.player?.currentItem
        )
    }
}
