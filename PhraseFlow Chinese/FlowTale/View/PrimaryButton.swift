//
//  PrimaryButton.swift
//  FlowTale
//
//  Created by iakalann on 17/01/2025.
//

import SwiftUI

struct PrimaryButton<Content: View>: View {
    @ViewBuilder let icon: Content
    let title: String
    let action: (() -> Void)?

    init(@ViewBuilder icon: () -> Content = { EmptyView() },
         title: String,
         action: (() -> Void)? = nil) {
        self.icon = icon()
        self.title = title
        self.action = action
    }

    var body: some View {
        if let act = action {
            Button {
                act()
            } label: {
                HStack(spacing: 5) {
                    icon
                    Text(title)
                }
                .padding()
                .background(FlowTaleColor.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        } else {
            HStack(spacing: 5) {
                icon
                Text(title)
            }
            .padding()
            .background(FlowTaleColor.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
