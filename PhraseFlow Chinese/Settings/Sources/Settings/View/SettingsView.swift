//
//  SettingsView.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import Audio
import SwiftUI
import FTColor
import Localization
import UserLimit

struct SettingsView: View {
    @EnvironmentObject var store: SettingsStore

    var body: some View {

        let shouldPlayButtonSounds: Binding<Bool> = .init {
            store.state.shouldPlaySound
        } set: { newValue in
            store.dispatch(.updateShouldPlaySound(newValue))
        }

        let selectedLanguage: Binding<Language> = .init {
            store.state.language
        } set: { newValue in
            store.dispatch(.updateLanguage(newValue))
        }
        NavigationStack {
            VStack {
                UserLimitRootView(remainingCharacters: store.state.remainingCharacters,
                                  totalLimit: store.state.characterLimitPerDay,
                                  isSubscribedUser: store.state.isSubscribedUser,
                                  timeUntilReset: store.state.timeUntilReset)
                ScrollView {
                    VStack(spacing: 12) {
                        // Usage Limit Section
                        settingsSection(
                            title: LocalizedString.storySettings,
                            content: {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8),
                                                         count: 2),
                                          spacing: 8) {
                                    NavigationLink(destination: LanguageSettingsView(selectedLanguage: selectedLanguage,
                                                                                     isEnabled: !store.state.viewState.isWritingChapter)) {
                                        settingImageView(
                                            title: store.state.language.displayName,
                                            image: store.state.language.thumbnail
                                        )
                                    }
                                    
                                    NavigationLink(destination: VoiceSettingsView()) {
                                        settingImageView(
                                            title: store.state.voice.title,
                                            image: store.state.voice.thumbnail
                                        )
                                    }
                                    
                                    NavigationLink(destination: DifficultySettingsView()) {
                                        settingImageView(
                                            title: store.state.difficulty.title,
                                            image: store.state.difficulty.thumbnail
                                        )
                                    }
                                    
                                    NavigationLink(destination: StoryPromptSettingsView()) {
                                        settingImageView(
                                            title: store.state.storySetting.title,
                                            image: store.state.storySetting.thumbnail
                                        )
                                    }
                                }
                                          .padding()
                            }
                        )
                        
                        AudioRootView(environment: store.environment.audioEnvironment)
                        
                        settingsSection(
                            title: LocalizedString.settingsSoundHeader,
                            content: {
                                VStack(spacing: 12) {
                                    settingsToggleRow(LocalizedString.settingsSounds, isOn: shouldPlayButtonSounds)
                                }
                            }
                        )
                    }
                }
            }
            .padding()
            .background(FTColor.background.color)
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func settingImageView(title: String, image: UIImage?) -> some View {
        ImageButton(
            title: title,
            image: image,
            isSelected: false,
            action: {
                /* No action */
            }
        )
        .disabled(true)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(FTColor.secondary.color)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private func settingsToggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .fontWeight(.light)
                .foregroundColor(FTColor.primary.color)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}
