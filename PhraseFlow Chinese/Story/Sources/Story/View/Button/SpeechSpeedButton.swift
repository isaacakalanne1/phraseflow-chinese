//
//  SpeechSpeedButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI
import FTFont
import FTColor

struct SpeechSpeedButton: View {
    @EnvironmentObject var store: StoryStore

    var body: some View {
        Button {
            store.dispatch(.updateSpeechSpeed(store.state.settingsState.speechSpeed.nextSpeed))
            store.dispatch(.playSound(.changeSettings))
        } label: {
            Text(store.state.settingsState.speechSpeed.text)
                .font(FTFont.flowTaleBodyMedium())
                .fontWeight(.medium)
                .foregroundStyle(FTColor.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(FTColor.background.opacity(0.9))
                        .overlay(Capsule().strokeBorder(FTColor.accent, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                )
        }
    }
}
