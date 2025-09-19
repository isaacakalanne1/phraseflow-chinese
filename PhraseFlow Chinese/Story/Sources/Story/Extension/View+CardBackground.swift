//
//  View+CardBackground.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI
import FTColor

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FTColor.background.color)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(FTColor.secondary.color, lineWidth: 1)
                        )
                }
        }
    }
}

public extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}
