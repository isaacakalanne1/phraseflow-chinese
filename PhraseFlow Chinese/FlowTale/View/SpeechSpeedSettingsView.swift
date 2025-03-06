//
//  SpeechSpeedSettingsView.swift
//  FlowTale
//
//  Created by iakalann on 23/01/2025.
//

import SwiftUI

struct SpeechSpeedMenu: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        List {
            Section {
                ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                    let isSelectedSpeed = store.state.settingsState.speechSpeed == speed

                    Button(action: {
                        withAnimation(.easeInOut) {
                            store.dispatch(.playSound(.changeSettings))
                            store.dispatch(.pauseAudio)
                            store.dispatch(.updateSpeechSpeed(speed))
                        }
                    }) {
                        Text(speed.emoji + " " + speed.title)
                            .foregroundStyle(isSelectedSpeed ? FlowTaleColor.accent : FlowTaleColor.primary)
                            .fontWeight(isSelectedSpeed ? .medium : .light)
                    }
                    .listRowBackground(isSelectedSpeed ? FlowTaleColor.secondary : Color(uiColor: UIColor.secondarySystemGroupedBackground))
                }
            } header: {
                Text(LocalizedString.speechSpeedMenuHeader)
            }
        }
        .navigationTitle(LocalizedString.speechSpeedNavTitle)
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
    }
}

struct SpeechSpeedSettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            SpeechSpeedMenu()

            PrimaryButton(title: LocalizedString.done) {
                dismiss()
            }
            .padding()
        }
        .background(FlowTaleColor.background)
    }
}
