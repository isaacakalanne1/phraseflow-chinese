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
            type.iconView
            Text(type.text)
                .foregroundStyle(FTColor.background)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(type.backgroundColor)
        .foregroundStyle(FTColor.primary)
        .cornerRadius(15)
        .multilineTextAlignment(.center)
        .padding()
        .zIndex(Double.infinity)
    }
}
