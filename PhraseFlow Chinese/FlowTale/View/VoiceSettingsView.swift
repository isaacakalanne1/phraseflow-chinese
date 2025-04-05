//
//  VoiceSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 23/01/2025.
//

import SwiftUI

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
                            
                            ImageSelectionButton(
                                title: voice.title,
                                image: voice.thumbnail,
                                fallbackText: voice.gender.emoji,
                                isSelected: isSelectedVoice,
                                action: {
                                    withAnimation(.easeInOut) {
                                        store.dispatch(.playSound(.changeSettings))
                                        store.dispatch(.selectVoice(voice))
                                        if shouldDismissOnSelect {
                                            dismiss()
                                        }
                                    }
                                }
                            )
                            .disabled(store.state.viewState.isWritingChapter)
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
        VStack(spacing: 0) {
            VoiceMenu(shouldDismissOnSelect: true)

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(FlowTaleColor.background)
    }
}
