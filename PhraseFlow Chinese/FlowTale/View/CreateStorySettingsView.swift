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

        VStack {
            List {
                Section {
                    Button {
                        isShowingLanguageSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Group {
                                if let thumbnail = currentLanguage.thumbnail {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                } else {
                                    Text(currentLanguage.flagEmoji)
                                        .font(.system(size: 20))
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .cornerRadius(10)
                            Text(currentLanguage.displayName)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, isSelected: false)
                        }
                    }
                } header: {
                    Text(LocalizedString.language)
                }
                
                Section {
                    Button {
                        isShowingDifficultySettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            DifficultyView(difficulty: currentDifficulty)
                            Text(currentDifficulty.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, isSelected: false)
                        }
                    }
                } header: {
                    Text(LocalizedString.difficulty)
                }

                Section {
                    Button {
                        isShowingPromptSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Text(currentStorySetting.emoji + " " + currentStorySetting.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                                .lineLimit(1)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, isSelected: false)
                        }
                    }
                } header: {
                    Text(LocalizedString.story)
                }

                Section {
                    Button {
                        isShowingVoiceSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Group {
                                if let thumbnail = currentVoice.thumbnail {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                } else {
                                    Text(currentVoice.gender.emoji)
                                        .font(.system(size: 20))
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .cornerRadius(10)
                            Text(currentVoice.title)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                                .lineLimit(1)
                            Spacer()
                            SystemImageView(.chevronRight, size: 20, isSelected: false)
                        }
                    }
                } header: {
                    Text(LocalizedString.voice)
                }

            }
            .frame(maxHeight: .infinity)
            .scrollBounceBehavior(.basedOnSize)

            CreateStoryButton()
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .bottom])
        }
        .navigationTitle(LocalizedString.createStory)
        .background(backgroundView)
        .scrollContentBackground(.hidden)
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
        Button {
            store.dispatch(.playSound(.createStory))
            
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
                HStack(spacing: 5) {
                    DifficultyView(difficulty: store.state.settingsState.difficulty, color: .white)
                    Text(store.state.settingsState.language.flagEmoji + " " + LocalizedString.newStory)
                        .fontWeight(.semibold)
                }
                .background(Color.clear)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .foregroundColor(.white)
            }
        }
        // Disable button if currently writing a chapter
        .disabled(store.state.viewState.isWritingChapter)
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
