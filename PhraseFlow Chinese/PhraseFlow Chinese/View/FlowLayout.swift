//
//  FlowLayout.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 26/10/2024.
//

import SwiftUI

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Variables to track size
        var width: CGFloat = 0
        var height: CGFloat = 0

        // Variables to track current line dimensions
        var currentLineWidth: CGFloat = 0
        var currentLineHeight: CGFloat = 0

        // Maximum width based on proposal or default to screen width
        let maxWidth = proposal.width ?? UIScreen.main.bounds.width

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            if currentLineWidth + subviewSize.width > maxWidth {
                // Move to next line
                width = max(width, currentLineWidth)
                height += currentLineHeight + spacing
                currentLineWidth = subviewSize.width
                currentLineHeight = subviewSize.height
            } else {
                currentLineWidth += subviewSize.width + spacing
                currentLineHeight = max(currentLineHeight, subviewSize.height)
            }
        }

        // Add the last line
        width = max(width, currentLineWidth)
        height += currentLineHeight

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Variables to track position
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY

        // Variables to track current line height
        var currentLineHeight: CGFloat = 0

        // Maximum width for wrapping
        let maxWidth = bounds.width

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            if x + subviewSize.width > bounds.maxX {
                // Move to next line
                x = bounds.minX
                y += currentLineHeight + spacing
                currentLineHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: subviewSize.width, height: subviewSize.height)
            )
            x += subviewSize.width + spacing
            currentLineHeight = max(currentLineHeight, subviewSize.height)
        }
    }
}
