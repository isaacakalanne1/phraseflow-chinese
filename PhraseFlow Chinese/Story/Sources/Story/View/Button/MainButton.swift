//
//  MainButton.swift
//  FlowTale
//
//  Created by iakalann on 07/03/2025.
//

import SwiftUI
import AVKit

struct MainButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                // Video background
                if let url = Bundle.main.url(forResource: "ButtonBackground", withExtension: "mp4") {
                    let player = AVPlayer(url: url)
                    VideoBackgroundView(player: player, autoPlay: true)
                        .frame(height: 70)
                        .overlay {
                            ColorFTColor.accent.opacity(0.6)
                        }
                        .cornerRadius(10)
                        .scaleEffect(x: -1, y: 1)
                }

                // Button content
                Text(title)
                    .font(.flowTaleBodyLarge())
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    MainButton(title: "Title") {
        print("Button tapped!")
    }
}
