//
//  AudioView.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import SwiftUI
import ReduxKit

struct AudioView: View {
    @EnvironmentObject var store: AudioStore
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
            
            Text(store.state.currentMusic.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Image(systemName: "speaker.wave.2.fill")
                .foregroundColor(.green)
                .font(.system(size: 12))
                .symbolEffect(.variableColor
                    .iterative
                    .dimInactiveLayers
                    .nonReversing)
                .opacity(store.state.isPlayingMusic ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}
