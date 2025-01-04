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

    var type: SnackBarType {
        store.state.snackBarState.type
    }

    var body: some View {
        HStack {
            type.iconView
            Text(type.text)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(type.isError ? FlowTaleColor.error : FlowTaleColor.accent)
        .cornerRadius(15)
        .foregroundColor(FlowTaleColor.background)
        .multilineTextAlignment(.center)
        .padding()
        .zIndex(Double.infinity)
        .onTapGesture {

        }
    }
}
