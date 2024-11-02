//
//  CategoryButtonView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 02/11/2024.
//

import SwiftUI

struct CategoryButtonView: View {
    @EnvironmentObject var store: FastChineseStore
    
    let imageUrl: URL?
    let title: String
    let isHighlighted: Bool
    let action:  () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                action()
            }
        }) {
            VStack(spacing: 4) {
                AsyncImage(url: imageUrl) { phase in
                    let image = phase.image?.resizable() ?? Image(uiImage: UIImage())
                    image
                        .frame(width: 100, height: 70)
                        .overlay(
                            Group {
                                if isHighlighted {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.accent, lineWidth: 5)
                                }
                            }
                        )
                        .clipShape(.rect(cornerRadius: 10))
                }
                Text(title)
                    .fontWeight(isHighlighted ? .medium : .light)
                    .foregroundStyle(isHighlighted ? Color.accent : Color.black)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}
