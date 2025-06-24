//
//  AudioButton.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI

struct AudioButton: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        Button {
            if store.state.audioState.isPlayingAudio {
                store.dispatch(.audioAction(.pauseAudio))
            } else {
                let timestamps = store.state.storyState.currentSentence?.timestamps ?? []
                let currentSpokenWord = store.state.storyState.currentSpokenWord ?? timestamps.first
                store.dispatch(.audioAction(.playAudio(time: currentSpokenWord?.time)))
            }
        } label: {
            audioButtonLabel(systemImage: store.state.audioState.isPlayingAudio ? .pause : .play)
        }
    }

    @ViewBuilder
    private func audioButtonLabel(systemImage: SystemImage) -> some View {
        Image(systemName: systemImage.systemName)
            .font(.system(size: 30))
            .foregroundColor(FlowTaleColor.accent)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(FlowTaleColor.background)
                    .overlay(Circle().strokeBorder(FlowTaleColor.accent, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
    }
}
