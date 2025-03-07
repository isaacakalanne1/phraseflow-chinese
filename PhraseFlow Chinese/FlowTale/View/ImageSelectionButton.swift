//
//  ImageSelectionButton.swift
//  FlowTale
//
//  Created by Claude on 05/03/2025.
//

import SwiftUI

struct ImageSelectionButton: View {
    let title: String
    let image: UIImage?
    let fallbackText: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Group {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            // Fallback if image is nil
                            ZStack {
                                Color.gray.opacity(0.3)
                                Text(fallbackText)
                                    .font(.system(size: 40))
                            }
                        }
                    }

                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: Color.black.opacity(0), location: 0.5),
                                .init(color: Color.black.opacity(1), location: 1.0)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Title on top of the gradient
                    VStack {
                        Spacer()
                        Text(title)
                            .fontWeight(isSelected ? .bold : .regular)
                            .foregroundStyle(isSelected ? FlowTaleColor.accent : Color.white)
                            .padding(.bottom, 8)
                            .padding(.horizontal, 8)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? FlowTaleColor.accent : Color.clear, lineWidth: 6)
                )
                .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .cornerRadius(12)
        }
    }
}