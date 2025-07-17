//
//  SpeechSpeedButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI

struct SpeechSpeedButton: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        Button {
            store.dispatch(.appSettingsAction(.updateSpeechSpeed(store.state.settingsState.speechSpeed.nextSpeed)))
            store.dispatch(.audioAction(.playSound(.changeSettings)))
        } label: {
            Text(store.state.settingsState.speechSpeed.text)
                .font(.flowTaleBodyMedium())
                .fontWeight(.medium)
                .foregroundStyle(.ftPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ftBackground.opacity(0.9))
                        .overlay(Capsule().strokeBorder(FTColor.accent, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                )
        }
    }
}
