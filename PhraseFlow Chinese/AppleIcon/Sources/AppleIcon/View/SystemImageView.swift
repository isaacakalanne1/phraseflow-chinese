//
//  SystemImageView.swift
//  FlowTale
//
//  Created by iakalann on 19/12/2024.
//

import FTColor
import SwiftUI

public struct SystemImageView: View {
    private let systemImage: SystemImage
    private let size: CGFloat
    private let isSelected: Bool

    public init(_ systemImage: SystemImage,
         size: CGFloat = 40,
         isSelected: Bool = true)
    {
        self.systemImage = systemImage
        self.size = size
        self.isSelected = isSelected
    }

    public var body: some View {
        let baseColor: Color = isSelected ? FTColor.accent : FTColor.primary
        let bottomColor: Color = isSelected ?
            FTColor.accent.opacity(0.7) // Accent with opacity for selected (simulates black overlay)
            : FTColor.primary.opacity(0.7) // Darker version for non-selected

        Image(systemName: systemImage.systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundStyle(LinearGradient(
                gradient: Gradient(colors: [baseColor, bottomColor]),
                startPoint: .top,
                endPoint: .bottom
            ))
    }
}
