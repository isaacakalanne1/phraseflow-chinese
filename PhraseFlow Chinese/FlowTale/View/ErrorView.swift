//
//  ErrorView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ErrorView: View {
    let title: String
    let buttonTitle: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.body)
            Button(buttonTitle) {
                buttonAction()
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
