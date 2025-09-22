//
//  SnackBar.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation
import SwiftUI
import FTColor

public struct SnackBarContentView: View {
    @EnvironmentObject private var store: SnackBarStore

    var type: SnackBarType {
        store.state.type
    }

    public var body: some View {
        HStack {
            Text(type.emoji)
            Text(type.text)
                .foregroundStyle(FTColor.background.color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(type.backgroundColor)
        .foregroundStyle(FTColor.primary.color)
        .cornerRadius(15)
        .multilineTextAlignment(.center)
        .padding()
        .zIndex(Double.infinity)
        .offset(y: store.state.isShowing ? 0 : -200)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: store.state.isShowing)
    }
}
