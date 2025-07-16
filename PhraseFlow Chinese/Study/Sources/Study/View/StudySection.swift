//
//  StudySection.swift
//  FlowTale
//
//  Created by iakalann on 13/07/2025.
//

import SwiftUI

struct StudySection<Content: View>: View {
    let title: String
    var isShown: Bool
    let content: Content

    var body: some View {
        VStack {
            Text(title)
                .greyBackground()
            content
                .scaleEffect(x: 1, y: isShown ? 1 : 0, anchor: .top)
                .opacity(isShown ? 1 : 0)
        }
    }
}
