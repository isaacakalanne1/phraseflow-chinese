//
//  View+CardBackground.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ftBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.ftSecondary, lineWidth: 1)
                        )
                }
        }
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackground())
    }
}
