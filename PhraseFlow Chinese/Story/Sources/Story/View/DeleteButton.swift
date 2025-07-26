//
//  Deleteutton.swift
//  FlowTale
//
//  Created by iakalann on 31/05/2025.
//

import SwiftUI
import Localization

struct DeleteButton: View {

    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: {
            action()
        }) {
            Label(LocalizedString.delete, systemImage: "trash")
        }
    }
}
