//
//  SnackBar.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import Foundation
import SwiftUI

struct SnackBar: View {
    @EnvironmentObject private var store: FlowTaleStore

    var body: some View {
        HStack {
            store.state.snackBarState.type.iconView
            Text(store.state.snackBarState.type.text)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .cornerRadius(15)
        .foregroundColor(Color.white)
        .multilineTextAlignment(.center)
        .padding()
        .zIndex(Double.infinity)
        .onTapGesture {

        }
    }
}
