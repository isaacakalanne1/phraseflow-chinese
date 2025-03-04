//
//  ActionButton.swift
//  FlowTale
//
//  Created by iakalann on 01/11/2024.
//

import SwiftUI

struct ActionButton: View {
    let systemImage: SystemImage
    let isSelected: Bool
    let size: CGFloat
    let action: () -> Void

    init(systemImage: SystemImage,
         isSelected: Bool,
         size: CGFloat = 35,
         action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            SystemImageView(systemImage,
                            size: size,
                            isSelected: isSelected)
        }
    }
}
