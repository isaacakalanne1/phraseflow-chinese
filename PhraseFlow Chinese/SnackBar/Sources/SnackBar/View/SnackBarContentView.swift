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
        GeometryReader { geometry in
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
            .offset(x: store.state.isShowing ? 0 : -geometry.size.width)
            .animation(.smooth, value: store.state.isShowing)
        }
        .zIndex(Double.infinity)
        .allowsHitTesting(store.state.isShowing)
    }
}
