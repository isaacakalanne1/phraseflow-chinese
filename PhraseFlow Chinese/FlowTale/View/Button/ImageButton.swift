//
//  ImageButton.swift
//  FlowTale
//
//  Created by Claude on 05/03/2025.
//

import SwiftUI

struct ImageButton: View {
    let title: String
    let image: UIImage?
    let isSelected: Bool
    let isTextCentered: Bool
    let action: () -> Void
    
    init(
        title: String,
        image: UIImage?,
        isSelected: Bool,
        isTextCentered: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.isSelected = isSelected
        self.isTextCentered = isTextCentered
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }

                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: Color.black.opacity(isTextCentered ? 1 : 0),
                                  location: 0.0),
                            .init(color: Color.black.opacity(isTextCentered ? 1 : 0), location: 0.5),
                            .init(color: Color.black.opacity(1), location: 1.0)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack {
                    if !isTextCentered {
                        Spacer()
                    }
                    Text(title)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundStyle(isSelected ? .ftAccent : Color.white)
                        .lineLimit(5)
                        .truncationMode(.tail)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 8)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .ftAccent : Color.clear, lineWidth: 6)
            )
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .cornerRadius(12)
        }
    }
}
