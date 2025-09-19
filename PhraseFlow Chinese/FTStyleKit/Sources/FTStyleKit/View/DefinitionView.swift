//
//  DefinitionView.swift
//  FTStyleKit
//
//  Created by Isaac Akalanne on 26/07/2025.
//

import SwiftUI
import FTFont
import FTColor
import Localization

public struct DefinitionViewData {
    public let word: String
    public let pronounciation: String
    public let definition: String
    public let definitionInContextOfSentence: String
    
    public init(word: String, pronounciation: String, definition: String, definitionInContextOfSentence: String) {
        self.word = word
        self.pronounciation = pronounciation
        self.definition = definition
        self.definitionInContextOfSentence = definitionInContextOfSentence
    }
}

public struct DefinitionView: View {
    let isLoading: Bool
    let viewData: DefinitionViewData?
    
    public init(isLoading: Bool, viewData: DefinitionViewData?) {
        self.isLoading = isLoading
        self.viewData = viewData
    }

    public var body: some View {
        VStack(spacing: 10) {
            if let viewData {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 6) {
                        Text(viewData.word)
                            .font(FTFont.header.font)
                            .fontWeight(.bold)
                            .foregroundColor(FTColor.primary.color)
                        Text(viewData.pronounciation)
                            .font(FTFont.bodyMedium.font)
                            .italic()
                            .foregroundColor(FTColor.accent.color)
                    }

                    Text(viewData.definition)
                        .font(FTFont.bodyMedium.font)
                        .foregroundColor(FTColor.primary.color)
                        .padding(.horizontal, 4)

                    Divider()

                    Text(viewData.definitionInContextOfSentence)
                        .font(FTFont.bodyMedium.font)
                        .foregroundColor(FTColor.primary.color)
                        .multilineTextAlignment(.leading)
                        .frame(maxHeight: .infinity)
                }
                .padding()
            } else if isLoading {
                // Loading state when no definition is available yet
                HStack {
                    Text("🔍 \(LocalizedString.loading)")
                        .font(FTFont.secondaryHeader.font)
                        .foregroundColor(FTColor.secondary.color)
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding()
                        .foregroundStyle(FTColor.primary.color)
                }
            } else {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .foregroundColor(FTColor.secondary.color)
                        Text("👆")
                    }
                    .font(FTFont.bodyMedium.font)
                    .padding(.bottom, 10)
                    
                    Text(LocalizedString.tapAWordToDefineIt)
                        .font(FTFont.secondaryHeader.font)
                        .foregroundColor(FTColor.secondary.color)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}
