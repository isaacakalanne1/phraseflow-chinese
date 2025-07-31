//
//  LoadingProgressBar.swift
//  FlowTale
//
//  Created by iakalann on 25/06/2025.
//

import FTColor
import FTFont
import Localization
import SwiftUI

public struct LoadingProgressBar: View {
    @EnvironmentObject var store: LoadingStore
    
    private var loadingStatus: LoadingStatus {
        store.state.loadingStatus
    }
    
    private var progress: Double {
        return Double(loadingStatus.progressInt) / 3.0
    }
    
    private var statusText: String {
        switch loadingStatus {
        case .writing:
            return LocalizedString.writingChapter
        case .generatingImage:
            return "Generating image..." // TODO: Localize
        case .generatingSpeech:
            return "Generating speech..."
        case .complete:
            return LocalizedString.chapterReady
        case .generatingDefinitions:
            return "Generating definitions..."
        }
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(statusText)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(FTColor.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ProgressStep(
                        icon: "doc.text",
                        title: "Writing",
                        isCompleted: loadingStatus.progressInt > 0,
                        isCurrent: loadingStatus == .writing,
                        isCompact: true
                    )
                    
                    ProgressStep(
                        icon: "photo",
                        title: "Image",
                        isCompleted: loadingStatus.progressInt > 1,
                        isCurrent: loadingStatus == .generatingImage,
                        isCompact: true
                    )
                    
                    ProgressStep(
                        icon: "speaker.wave.3",
                        title: "Audio",
                        isCompleted: loadingStatus.progressInt > 2,
                        isCurrent: loadingStatus == .generatingSpeech,
                        isCompact: true
                    )
                }
            }
            
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: FTColor.accent))
                .scaleEffect(y: 0.8)
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(FTColor.background)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 16)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}

struct ProgressStep: View {
    let icon: String
    let title: String
    let isCompleted: Bool
    let isCurrent: Bool
    let isCompact: Bool
    
    var body: some View {
        if isCompact {
            // Compact version - just the circle
            ZStack {
                Circle()
                    .fill(
                        isCompleted ? FTColor.accent :
                        isCurrent ? FTColor.accent.opacity(0.3) :
                        FTColor.secondary.opacity(0.2)
                    )
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(FTFont.flowTaleBodyXSmall())
                        .foregroundColor(.white)
                } else if isCurrent {
                    ProgressView()
                        .scaleEffect(0.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: FTColor.accent))
                } else {
                    Image(systemName: icon)
                        .font(FTFont.flowTaleBodyXSmall())
                        .foregroundColor(FTColor.secondary.opacity(0.6))
                }
            }
        } else {
            // Full version with title
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            isCompleted ? FTColor.accent :
                            isCurrent ? FTColor.accent.opacity(0.3) :
                            FTColor.secondary.opacity(0.2)
                        )
                        .frame(width: 40, height: 40)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(FTFont.flowTaleBodySmall())
                            .foregroundColor(.white)
                    } else if isCurrent {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: FTColor.accent))
                    } else {
                        Image(systemName: icon)
                            .font(FTFont.flowTaleBodySmall())
                            .foregroundColor(FTColor.secondary.opacity(0.6))
                    }
                }
                
                Text(title)
                    .font(FTFont.flowTaleSecondaryHeader())
                    .foregroundColor(
                        isCompleted || isCurrent ? FTColor.primary : FTColor.secondary
                    )
            }
        }
    }
}
