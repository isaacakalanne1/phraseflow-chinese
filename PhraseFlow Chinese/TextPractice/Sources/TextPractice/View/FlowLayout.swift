//
//  FlowLayout.swift
//  FlowTale
//
//  Created by iakalann on 26/10/2024.
//

import SwiftUI
import Settings

public struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    var language: Language?
    
    public init(spacing: CGFloat,
                language: Language? = nil) {
        self.spacing = spacing
        self.language = language
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        // Variables to track size
        var width: CGFloat = 0
        var height: CGFloat = 0

        // Variables to track current line dimensions
        var currentLineWidth: CGFloat = 0
        var currentLineHeight: CGFloat = 0

        // Maximum width based on proposal or default to screen width
        let maxWidth = proposal.width ?? 400

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

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY

        var currentLineHeight: CGFloat = 0

        if let lang = language,
           lang == .arabicGulf
        {
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                if x - subviewSize.width < bounds.minX {
                    // Move to next line
                    x = bounds.maxX
                    y += currentLineHeight + spacing
                    currentLineHeight = 0
                }

                x -= subviewSize.width - spacing
                subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: subviewSize.width, height: subviewSize.height)
                )
                currentLineHeight = max(currentLineHeight, subviewSize.height)
            }
        } else {
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
}
