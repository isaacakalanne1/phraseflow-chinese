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
                            .font(FTFont.flowTaleHeader())
                            .fontWeight(.bold)
                            .foregroundColor(FTColor.primary)
                        Text(viewData.pronounciation)
                            .font(FTFont.flowTaleBodyMedium())
                            .italic()
                            .foregroundColor(FTColor.accent)
                    }

                    Text(viewData.definition)
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.primary)
                        .padding(.horizontal, 4)

                    Divider()

                    Text(viewData.definitionInContextOfSentence)
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxHeight: .infinity)
                }
                .padding()
            } else if isLoading {
                // Loading state when no definition is available yet
                HStack {
                    Text("🔍 \(LocalizedString.loading)")
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.secondary)
                    ProgressView()
                        .padding()
                        .foregroundStyle(FTColor.primary)
                }
            } else {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.tap")
                            .foregroundColor(FTColor.secondary)
                        Text("👆")
                    }
                    .font(FTFont.flowTaleBodyMedium())
                    .padding(.bottom, 10)
                    
                    Text(LocalizedString.tapAWordToDefineIt)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(FTColor.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}
