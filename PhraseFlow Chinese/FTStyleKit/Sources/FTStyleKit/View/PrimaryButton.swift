//
//  PrimaryButton.swift
//  FlowTale
//
//  Created by iakalann on 17/01/2025.
//

import SwiftUI
import FTColor

public struct PrimaryButton<Content: View>: View {
    @ViewBuilder let icon: Content
    let title: String
    let action: (() -> Void)

    public init(@ViewBuilder icon: () -> Content = { EmptyView() },
         title: String,
         action: @escaping (() -> Void)) {
        self.icon = icon()
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 5) {
                icon
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(FTColor.accent.color)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
