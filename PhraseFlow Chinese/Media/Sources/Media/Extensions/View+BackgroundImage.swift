//
//  View+CardBackground.swift
//  FlowTale
//
//  Created by iakalann on 18/04/2025.
//

import FTColor
import SwiftUI

public struct BackgroundImage: ViewModifier {
    let type: BackgroundImageType

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) { // TODO: Remove if not needed
            content
                .background {
                    Group {
                        if let uiImage = UIImage(named: type.name) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .overlay {
                                    FTColor.background.opacity(0.9)
                                }
                        }
                    }
                }
        }
    }
}

public extension View {
    func backgroundImage(type: BackgroundImageType) -> some View {
        modifier(BackgroundImage(type: type))
    }
}
