//
//  SystemImage.swift
//  FlowTale
//
//  Created by iakalann on 19/12/2024.
//

import SwiftUI

struct SystemImageView: View {

    private let systemImage: SystemImage
    private let size: CGFloat
    private let color: Color

    init(_ systemImage: SystemImage,
         size: CGFloat = 40,
         color: Color = FlowTaleColor.accent) {
        self.systemImage = systemImage
        self.size = size
        self.color = color
    }

    var body: some View {
        Image(systemName: systemImage.systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}
