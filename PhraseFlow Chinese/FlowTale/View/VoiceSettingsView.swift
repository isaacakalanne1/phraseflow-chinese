//
//  VoiceSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 23/01/2025.
//

import SwiftUI

struct VoiceOnboardingView: View {
    var body: some View {
        VStack {
            VoiceMenu()
            NavigationLink {
                SpeechSpeedOnboardingView()
            } label: {
                PrimaryButton(title: LocalizedString.next)
            }
        }
        .background(FlowTaleColor.background)
    }
}

struct VoiceMenu: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(LocalizedString.voiceMenuHeader)
//                    .font(.headline)
                    .foregroundColor(FlowTaleColor.primary)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Get voices from either currentStory or directly from the current language setting
                let voices = store.state.settingsState.language.voices
                let sortedVoices = voices.sorted(by: { $0.gender.title < $1.gender.title })
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(sortedVoices, id: \.self) { voice in
                        let isSelectedVoice = store.state.settingsState.voice == voice
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.dispatch(.playSound(.changeSettings))
                                store.dispatch(.selectVoice(voice))
                                if shouldDismissOnSelect {
                                    dismiss()
                                }
                            }
                        }) {
                            VStack {
                                Group {
                                    if let thumbnail = voice.thumbnail {
                                        Image(uiImage: thumbnail)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
//                                            .frame(width: 100, height: 100)
                                    } else {
                                        // Fallback if thumbnail is nil
                                        ZStack {
                                            Color.gray.opacity(0.3)
                                            Text(voice.gender.emoji)
                                                .font(.system(size: 40))
                                        }
//                                        .frame(width: 100, height: 100)
                                    }
                                }
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelectedVoice ? FlowTaleColor.accent : Color.clear, lineWidth: 3)
                                )
                                
                                Text(voice.title)
                                    .fontWeight(isSelectedVoice ? .bold : .regular)
                                    .foregroundColor(isSelectedVoice ? FlowTaleColor.accent : FlowTaleColor.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
//                            .background(isSelectedVoice ? FlowTaleColor.secondary.opacity(0.3) : Color.clear)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .onAppear {
                    if store.state.storyState.currentStory == nil,
                       let voice = voices.first {
                        store.dispatch(.selectVoice(voice))
                    }
                }
            }
        }
        .navigationTitle(LocalizedString.voice)
        .background(FlowTaleColor.background)
    }
}

struct VoiceSettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            VoiceMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding()
        }
        .background(FlowTaleColor.background)
    }
}
