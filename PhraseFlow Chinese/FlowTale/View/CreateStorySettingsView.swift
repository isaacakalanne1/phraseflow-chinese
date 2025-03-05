//
//  CreateStorySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 22/11/2024.
//

import SwiftUI

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

        VStack {
            List {
                Section {
                    Button {
                        isShowingLanguageSettings = true
                        store.dispatch(.playSound(.openStorySettings))
                    } label: {
                        HStack {
                            Text(currentLanguage.flagEmoji + " " + currentLanguage.displayName)
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
                                if let thumbnail = store.state.settingsState.voice.thumbnail {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 50)
                                } else {
                                    Text(store.state.settingsState.voice.gender.emoji)
                                        .font(.system(size: 20))
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .cornerRadius(10)
                            Text(store.state.settingsState.voice.title)
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
        .background(FlowTaleColor.background)
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
}

struct CreateStoryButton: View {
    @EnvironmentObject var store: FlowTaleStore

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
            HStack(spacing: 5) {
                DifficultyView(difficulty: store.state.settingsState.difficulty, color: FlowTaleColor.primary)
                Text(store.state.settingsState.language.flagEmoji + " " + LocalizedString.newStory)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(FlowTaleColor.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        // Disable button if currently writing a chapter
        .disabled(store.state.viewState.isWritingChapter)
    }
}
