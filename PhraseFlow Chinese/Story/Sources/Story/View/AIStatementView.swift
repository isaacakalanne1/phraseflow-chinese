//
//  AIStatementView.swift
//  FlowTale
//
//  Created by iakalann on 19/12/2024.
//

import SwiftUI
import FTFont
import FTColor

struct AIStatementView: View {
    var body: some View {
        Text(LocalizedString.aiStatement)
            .font(FTFont.flowTaleBodyXSmall())
            .foregroundStyle(FTColor.primary.opacity(0.3))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}
