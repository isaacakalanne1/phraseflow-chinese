//
//  SectionView.swift
//  FTStyleKit
//
//  Created by Isaac Akalanne on 13/09/2025.
//

import SwiftUI
import FTColor

public struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(FTColor.secondary.color)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}
