//
//  ImageButton.swift
//  FlowTale
//
//  Created by iakalann on 05/03/2025.
//

import SwiftUI
import FTColor
import FTFont

public struct ImageButton: View {
    let title: String
    let image: UIImage?
    let isSelected: Bool
    let action: () -> Void
    
    public init(
        title: String,
        image: UIImage?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    FTColor.background.opacity(0.3),
                                    FTColor.background.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                }

                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: Color.black.opacity(0),
                                  location: 0.0),
                            .init(color: Color.black.opacity(0), location: 0.5),
                            .init(color: Color.black.opacity(1), location: 1.0)

                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    Spacer()
                    Text(title)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium, design: .rounded))
                        .foregroundStyle(isSelected ? FTColor.accent : Color.white)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 8)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? 
                        LinearGradient(
                            gradient: Gradient(colors: [FTColor.accent, FTColor.accent.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(16)
            .frame(maxWidth: .infinity)
            .aspectRatio(1.0, contentMode: .fit)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? FTColor.accent.opacity(0.3) : Color.black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
    }
}
