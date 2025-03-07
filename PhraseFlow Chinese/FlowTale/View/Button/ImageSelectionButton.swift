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
    let useFullButtonText: Bool
    let action: () -> Void
    
    init(
        title: String,
        image: UIImage?,
        fallbackText: String,
        isSelected: Bool,
        useFullButtonText: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.fallbackText = fallbackText
        self.isSelected = isSelected
        self.useFullButtonText = useFullButtonText
        self.action = action
    }
    
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

                    // Full button overlay or gradient overlay
                    if useFullButtonText {
                        // Full black overlay for full button text
                        Rectangle()
                            .fill(Color.black.opacity(0.7))
                    } else {
                        // Gradient overlay for bottom text
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
                    }

                    // Title display
                    if useFullButtonText {
                        // Text centered in the button
                        Text(title)
                            .fontWeight(isSelected ? .bold : .regular)
                            .foregroundStyle(isSelected ? FlowTaleColor.accent : Color.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(5)
                            .truncationMode(.tail)
                            .padding(12)
                    } else {
                        // Text at the bottom
                        VStack {
                            Spacer()
                            Text(title)
                                .fontWeight(isSelected ? .bold : .regular)
                                .foregroundStyle(isSelected ? FlowTaleColor.accent : Color.white)
                                .lineLimit(5)
                                .truncationMode(.tail)
                                .padding(.bottom, 8)
                                .padding(.horizontal, 8)
                        }
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
