//
//  MainButton.swift
//  FlowTale
//
//  Created by iakalann on 07/03/2025.
//

import SwiftUI
import FTFont
import AVKit
import FTColor

public struct MainButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String,
                action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
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
                            FTColor.accent.opacity(0.6)
                        }
                        .cornerRadius(10)
                        .scaleEffect(x: -1, y: 1)
                }

                // Button content
                Text(title)
                    .font(FTFont.flowTaleBodyLarge())
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
