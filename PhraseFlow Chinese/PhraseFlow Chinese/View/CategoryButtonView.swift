//
//  CategoryButtonView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 02/11/2024.
//

import SwiftUI

struct CategoryButtonView: View {
    let category: Categorisable
    let isHighlighted: Bool
    let action:  () -> Void

    var body: some View {
        Button(action: { withAnimation(.easeInOut) { action() } }) {
            VStack(spacing: 4) {
                AsyncImage(url: category.imageUrl) { phase in
                    (phase.image?.resizable() ?? Image(uiImage: UIImage()))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 70)
                        .overlay(
                            isHighlighted ? RoundedRectangle(cornerRadius: 10)
                                .stroke(.accent, lineWidth: 5) : nil
                        )
                        .clipShape(.rect(cornerRadius: 10))
                }
                Text(category.title)
                    .fontWeight(isHighlighted ? .medium : .light)
                    .foregroundStyle(isHighlighted ? Color.accent : Color.black)
                    .frame(alignment: .top)
            }
        }
    }
}
