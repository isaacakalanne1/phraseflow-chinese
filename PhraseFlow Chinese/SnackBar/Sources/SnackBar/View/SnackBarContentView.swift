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
            HStack(spacing: 12) {
                Text(type.emoji)
                    .font(.title2)
                    .scaleEffect(store.state.isShowing ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: store.state.isShowing)
                
                Text(type.text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(type.backgroundColor.gradient)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .scaleEffect(store.state.isShowing ? 1.0 : 0.95)
            .opacity(store.state.isShowing ? 1.0 : 0.0)
            .offset(y: store.state.isShowing ? 0 : -20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: store.state.isShowing)
        }
        .zIndex(Double.infinity)
        .allowsHitTesting(store.state.isShowing)
    }
}
