//
//  CreateStorySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 22/11/2024.
//

import AVKit
import FTStyleKit
import Localization
import SwiftUI

struct CreateStorySettingsView: View {
    @EnvironmentObject var store: SettingsStore

    @State var isShowingLanguageSettings = false
    @State var isShowingDifficultySettings = false
    @State var isShowingPromptSettings = false
    @State var isShowingVoiceSettings = false

    var body: some View {
        let currentDifficulty = store.state.difficulty
        let currentLanguage = store.state.language
        let currentVoice = store.state.voice

        return VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12) {
                        ImageButton(
                            title: currentLanguage.displayName,
                            image: currentLanguage.thumbnail,
                            isSelected: false,
                            action: {
                                isShowingLanguageSettings = true
                                store.dispatch(.playSound(.openStorySettings))
                            }
                        )

                        ImageButton(
                            title: currentDifficulty.title,
                            image: currentDifficulty.thumbnail,
                            isSelected: false,
                            action: {
                                isShowingDifficultySettings = true
                                store.dispatch(.playSound(.openStorySettings))
                            }
                        )

                        storyPromptButton

                        ImageButton(
                            title: currentVoice.title,
                            image: currentVoice.thumbnail,
                            isSelected: false,
                            action: {
                                isShowingVoiceSettings = true
                                store.dispatch(.playSound(.openStorySettings))
                            }
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .backgroundImage(type: .createStory)
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
    }

    var storyPromptButton: some View {
        let promptImage: UIImage?
        let promptDisplayText: String

        switch store.state.storySetting {
        case .random:
            promptImage = UIImage(named: "StoryPrompt-Random")
            promptDisplayText = LocalizedString.random
        case let .customPrompt(prompt):
            promptImage = UIImage(named: "StoryPrompt-Custom")
            let firstLetter = prompt.prefix(1).capitalized
            let remainingLetters = prompt.dropFirst()
            promptDisplayText = firstLetter + remainingLetters
        }

        return ImageButton(
            title: promptDisplayText,
            image: promptImage,
            isSelected: false,
            isTextCentered: promptDisplayText.count > 20,
            action: {
                isShowingPromptSettings = true
                store.dispatch(.playSound(.openStorySettings))
            }
        )
    }
}
