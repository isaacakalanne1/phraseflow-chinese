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
    let isSelected: Bool
    let size: CGFloat
    let action: () -> Void

    init(title: String? = nil,
         systemImage: SystemImage,
         isSelected: Bool,
         size: CGFloat = 35,
         action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.size = size
        self.action = action
    }

    var body: some View {
        let color = isSelected ? FlowTaleColor.accent : FlowTaleColor.primary.opacity(0.7)
        Button(action: {
            action()
        }) {
            VStack {
                SystemImageView(systemImage,
                                size: size,
                                color: color)
                if let titleString = title {
                    Text(titleString)
                        .font(.system(size: 12, weight: .medium))
                        .frame(height: 25)
                }
            }
            .foregroundStyle(color)
        }
    }
}
