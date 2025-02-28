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

    var body: some View {
        List {
            Section {
                // Get voices from either currentStory or directly from the current language setting
                let voices = store.state.storyState.currentStory?.language.voices ?? 
                             store.state.settingsState.language.voices
                let sortedVoices = voices.sorted(by: { $0.gender.title < $1.gender.title })
                
                ForEach(sortedVoices, id: \.self) { voice in
                    let isSelectedVoice = store.state.settingsState.voice == voice

                    Button(action: {
                        withAnimation(.easeInOut) {
                            store.dispatch(.playSound(.changeSettings))
                            store.dispatch(.selectVoice(voice))
                        }
                    }) {
                        VStack(alignment: .leading) {
                            Text(voice.gender.emoji + " " + voice.title)
                                .fontWeight(isSelectedVoice ? .medium : .light)
                        }
                        .foregroundStyle(isSelectedVoice ? FlowTaleColor.accent : FlowTaleColor.primary)
                    }
                    .listRowBackground(isSelectedVoice ? FlowTaleColor.secondary : Color(uiColor: UIColor.secondarySystemGroupedBackground))
                }
                .onAppear {
                    if store.state.storyState.currentStory == nil,
                       let voice = voices.first {
                        store.dispatch(.selectVoice(voice))
                    }
                }
            } header: {
                Text(LocalizedString.voiceMenuHeader)
            }
        }
        .navigationTitle(LocalizedString.voice)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
    }
}

struct VoiceSettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            VoiceMenu()

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding()
        }
        .background(FlowTaleColor.background)
    }
}
