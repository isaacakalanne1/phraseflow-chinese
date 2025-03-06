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
            CreateStoryButton()
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
                
                // Get voices from either currentStory or directly from the current language setting
                let voices = store.state.settingsState.language.voices
                let sortedVoices = voices.sorted(by: { $0.gender.title < $1.gender.title })

                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
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
                                    ZStack {
                                        Group {
                                            if let thumbnail = voice.thumbnail {
                                                Image(uiImage: thumbnail)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } else {
                                                // Fallback if thumbnail is nil
                                                ZStack {
                                                    Color.gray.opacity(0.3)
                                                    Text(voice.gender.emoji)
                                                        .font(.system(size: 40))
                                                }
                                            }
                                        }
                                        
                                        // Gradient overlay
                                        LinearGradient(
                                            gradient: Gradient(
                                                stops: [
                                                    .init(color: Color.black.opacity(0), location: 0.5),
                                                    .init(color: Color.black.opacity(1), location: 1.0)
                                                ]
                                            ),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        
                                        // Voice name on top of the gradient
                                        VStack {
                                            Spacer()
                                            Text(voice.title)
                                                .fontWeight(isSelectedVoice ? .bold : .regular)
                                                .foregroundStyle(isSelectedVoice ? FlowTaleColor.accent : Color.white)
                                                .padding(.bottom, 8)
                                                .padding(.horizontal, 8)
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelectedVoice ? FlowTaleColor.accent : Color.clear, lineWidth: 6)
                                    )
                                    .cornerRadius(12)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
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
                } header: {
                    Text(LocalizedString.voiceMenuHeader.uppercased())
                        .font(.footnote)
                }
            }
        }
        .padding()
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
