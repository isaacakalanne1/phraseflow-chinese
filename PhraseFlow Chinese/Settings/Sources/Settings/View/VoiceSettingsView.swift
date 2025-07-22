//
//  VoiceSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 23/01/2025.
//

import SwiftUI
import FTColor
import FTFont

struct VoiceMenu: View {
    @EnvironmentObject var store: SettingsStore
    @Environment(\.dismiss) var dismiss
    var shouldDismissOnSelect = false

    var body: some View {
        ScrollView {
            let voices = store.state.settingsState.language.voices
            let sortedVoices = voices.sorted(by: { $0.gender.title < $1.gender.title })
            Section {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 8) {
                    ForEach(sortedVoices, id: \.self) { voice in
                        let isSelectedVoice = store.state.settingsState.voice == voice

                        ImageButton(
                            title: voice.title,
                            image: voice.thumbnail,
                            isSelected: isSelectedVoice,
                            action: {
                                withAnimation(.easeInOut) {
                                    store.dispatch(.audioAction(.playSound(.changeSettings)))
                                    store.dispatch(.appSettingsAction(.selectVoice(voice)))
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
                    .font(FTFont.flowTaleSubHeader())
            }
        }
        .padding()
        .navigationTitle(LocalizedString.voice)
        .background(FTColor.background)
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
        .background(FTColor.background)
    }
}
