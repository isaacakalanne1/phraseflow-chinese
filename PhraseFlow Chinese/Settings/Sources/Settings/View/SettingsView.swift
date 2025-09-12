//
//  SettingsView.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import SwiftUI
import FTColor
import Localization
import UserLimit

struct SettingsView: View {
    @EnvironmentObject var store: SettingsStore

    var body: some View {
        let showDefinition: Binding<Bool> = .init {
            store.state.isShowingDefinition
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            store.dispatch(.updateShowDefinition(newValue))
        }

        let showEnglish: Binding<Bool> = .init {
            store.state.isShowingEnglish
        } set: { newValue in
            store.dispatch(.playSound(.togglePress))
            store.dispatch(.updateShowEnglish(newValue))
        }

        let playMusic: Binding<Bool> = .init {
            store.state.isPlayingMusic
        } set: { newValue in
            if newValue {
                store.dispatch(.playMusic(.whispersOfTheForest))
            } else {
                store.dispatch(.stopMusic)
                store.dispatch(.playSound(.togglePress))
            }
        }

        let shouldPlayButtonSounds: Binding<Bool> = .init {
            store.state.shouldPlaySound
        } set: { newValue in
            store.dispatch(.updateShouldPlaySound(newValue))
            if newValue {
                store.dispatch(.playSound(.togglePress))
            }
        }

        let selectedLanguage: Binding<Language> = .init {
            store.state.language
        } set: { newValue in
            store.dispatch(.updateLanguage(newValue))
        }
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Usage Limit Section
                    usageLimitSection()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
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
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        settingsSection(
                            title: LocalizedString.settingsAppearance,
                            content: {
                                VStack(spacing: 12) {
                                    settingsToggleRow(LocalizedString.definitionToggle, isOn: showDefinition)
                                    settingsToggleRow(LocalizedString.translation, isOn: showEnglish)
                                }
                            }
                        )
                        
                        settingsSection(
                            title: LocalizedString.settingsSoundHeader,
                            content: {
                                VStack(spacing: 12) {
                                    settingsToggleRow(LocalizedString.music, isOn: playMusic)
                                    settingsToggleRow(LocalizedString.settingsSounds, isOn: shouldPlayButtonSounds)
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 16)
            }
            .background(FTColor.background)
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
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
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(FTColor.secondary)
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
                .foregroundColor(FTColor.primary)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
    
    @ViewBuilder
    private func usageLimitSection() -> some View {
        settingsSection(
            title: (store.state.isSubscribedUser == true) ? "DAILY USAGE" : "FREE TRIAL USAGE",
            content: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text((store.state.isSubscribedUser == true) ? "Characters Remaining Today" : "Characters Remaining")
                            .font(.caption)
                            .foregroundColor(FTColor.secondary)
                        
                        if let remainingCharacters = store.state.remainingCharacters {
                            Text("\(remainingCharacters)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(remainingCharacters > 0 ? FTColor.primary : .red)
                        } else {
                            Text("Loading...")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(FTColor.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if store.state.isSubscribedUser == true, let timeUntilReset = store.state.timeUntilReset {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Resets in")
                                .font(.caption)
                                .foregroundColor(FTColor.secondary)
                            
                            Text(timeUntilReset)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(FTColor.primary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        )
        .padding(.horizontal)
    }
}
