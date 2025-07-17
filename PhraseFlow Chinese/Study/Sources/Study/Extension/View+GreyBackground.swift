//
//  View+GreyBackground.swift
//  FlowTale
//
//  Created by iakalann on 31/10/2024.
//

import SwiftUI

struct GreyBackground: ViewModifier {
    let isShowing: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(4)
                .background {
                    if isShowing {
                        ColorFTColor.secondary
                            .clipShape(.rect(cornerRadius: 5))
                    }
                }
        }
    }
}

extension View {
    func greyBackground(isShowing: Bool = true) -> some View {
        modifier(GreyBackground(isShowing: isShowing))
    }
}
