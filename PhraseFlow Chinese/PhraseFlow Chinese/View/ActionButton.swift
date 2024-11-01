//
//  ActionButton.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 01/11/2024.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .frame(height: 25)
            }
            .foregroundStyle(Color.accentColor)
        }
    }
}
