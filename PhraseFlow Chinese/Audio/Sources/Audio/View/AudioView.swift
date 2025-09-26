//
//  AudioView.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import SwiftUI
import ReduxKit

struct AudioView: View {
    @EnvironmentObject private var store: AudioStore
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Now Playing")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(store.state.currentMusicType?.rawValue ?? "No Music Playing")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 30) {
                Button(action: {
                    store.dispatch(.previousMusic)
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .disabled(store.state.currentMusicType == nil)
                
                Button(action: {
                    if store.state.currentMusicType == nil {
                        // Start playing first music if none is playing
                        if let firstMusic = MusicType.allCases.first {
                            store.dispatch(.playMusic(music: firstMusic, volume: store.state.currentVolume))
                        }
                    } else if store.state.isPlayingMusic {
                        store.dispatch(.pauseMusic)
                    } else {
                        store.dispatch(.resumeMusic)
                    }
                }) {
                    Image(systemName: store.state.isPlayingMusic ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                
                Button(action: {
                    store.dispatch(.nextMusic)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .disabled(store.state.currentMusicType == nil)
            }
            
            HStack {
                Text("Volume")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    let newVolume: MusicVolume = store.state.currentVolume == .normal ? .quiet : .normal
                    store.dispatch(.setMusicVolume(newVolume))
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: store.state.currentVolume == .normal ? "speaker.2.fill" : "speaker.1.fill")
                        Text(store.state.currentVolume == .normal ? "Normal" : "Quiet")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}
