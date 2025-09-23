//
//  SpeechSpeedButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI
import FTFont
import FTColor
import ReduxKit
import Audio

public struct SpeechSpeedButton: View {
    @EnvironmentObject var store: TextPracticeStore

    public init() {}
    
    public var body: some View {
        Button {
            var settings = store.state.settings
            settings.speechSpeed = settings.speechSpeed.nextSpeed
            store.dispatch(.saveAppSettings(settings))
            store.dispatch(.playSound(.changeSettings))
        } label: {
            Text(store.state.settings.speechSpeed.text)
                .font(FTFont.bodySmall.font)
                .fontWeight(.medium)
                .foregroundStyle(FTColor.primary.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(width: 70)
                .background(
                    Capsule()
                        .fill(FTColor.background.color.opacity(0.9))
                        .overlay(Capsule().strokeBorder(FTColor.accent.color, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                )
        }
    }
}
