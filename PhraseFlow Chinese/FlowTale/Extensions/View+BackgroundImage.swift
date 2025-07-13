//
//  View+CardBackground.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import SwiftUI

struct BackgroundImage: ViewModifier {
    let type: BackgroundImageType

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .background {
                    Group {
                        if let uiImage = UIImage(named: type.name) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .overlay {
                                    Color.ftBackground.opacity(0.9)
                                }
                        }
                    }
                }
        }
    }
}

extension View {
    func backgroundImage(type: BackgroundImageType) -> some View {
        modifier(BackgroundImage(type: type))
    }
}
