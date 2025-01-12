//
//  ActionButton.swift
//  FlowTale
//
//  Created by iakalann on 01/11/2024.
//

import SwiftUI

struct ActionButton: View {
    let title: String?
    let systemImage: SystemImage
    let size: CGFloat
    let action: () -> Void

    init(title: String? = nil,
         systemImage: SystemImage,
         size: CGFloat = 35,
         action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                SystemImageView(systemImage, size: size)
                if let titleString = title {
                    Text(titleString)
                        .font(.system(size: 12, weight: .medium))
                        .frame(height: 25)
                }
            }
            .foregroundStyle(FlowTaleColor.accent)
        }
    }
}
