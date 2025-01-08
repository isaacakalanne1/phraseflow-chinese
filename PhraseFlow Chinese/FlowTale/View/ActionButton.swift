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
    let action: () -> Void

    init(title: String? = nil,
         systemImage: SystemImage,
         action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                SystemImageView(systemImage, size: 35)
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
