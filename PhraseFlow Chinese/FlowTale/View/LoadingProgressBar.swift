//
//  LoadingProgressBar.swift
//  FlowTale
//
//  Created by iakalann on 25/06/2025.
//

import SwiftUI

struct LoadingProgressBar: View {
    @EnvironmentObject var store: FlowTaleStore
    let isCentered: Bool
    
    init(isCentered: Bool = false) {
        self.isCentered = isCentered
    }
    
    private var loadingState: LoadingState {
        store.state.viewState.loadingState
    }
    
    private var isLoading: Bool {
        store.state.viewState.isWritingChapter
    }
    
    private var progress: Double {
        guard isLoading else { return 0 }
        return Double(loadingState.progressInt) / 3.0
    }
    
    private var statusText: String {
        switch loadingState {
        case .writing:
            return LocalizedString.writingChapter
        case .generatingImage:
            return "Generating image..."
        case .generatingSpeech:
            return "Generating speech..."
        case .complete:
            return LocalizedString.chapterReady
        }
    }
    
    var body: some View {
        if isLoading {
            if isCentered {
                // Full centered version for onboarding
                VStack(spacing: 12) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text(statusText)
                            .font(.flowTaleSecondaryHeader())
                            .foregroundColor(FlowTaleColor.primary)
                        
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: FlowTaleColor.accent))
                            .scaleEffect(y: 1.5)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                        
                        HStack(spacing: 16) {
                            ProgressStep(
                                icon: "doc.text",
                                title: "Writing",
                                isCompleted: loadingState.progressInt > 0,
                                isCurrent: loadingState == .writing,
                                isCompact: false
                            )
                            
                            ProgressStep(
                                icon: "photo",
                                title: "Image",
                                isCompleted: loadingState.progressInt > 1,
                                isCurrent: loadingState == .generatingImage,
                                isCompact: false
                            )
                            
                            ProgressStep(
                                icon: "speaker.wave.3",
                                title: "Audio",
                                isCompleted: loadingState.progressInt > 2,
                                isCurrent: loadingState == .generatingSpeech,
                                isCompact: false
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(FlowTaleColor.background)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            } else {
                // Compact version for top of screen
                VStack(spacing: 4) {
                    HStack {
                        Text(statusText)
                            .font(.flowTaleSecondaryHeader())
                            .foregroundColor(FlowTaleColor.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            ProgressStep(
                                icon: "doc.text",
                                title: "Writing",
                                isCompleted: loadingState.progressInt > 0,
                                isCurrent: loadingState == .writing,
                                isCompact: true
                            )
                            
                            ProgressStep(
                                icon: "photo",
                                title: "Image",
                                isCompleted: loadingState.progressInt > 1,
                                isCurrent: loadingState == .generatingImage,
                                isCompact: true
                            )
                            
                            ProgressStep(
                                icon: "speaker.wave.3",
                                title: "Audio",
                                isCompleted: loadingState.progressInt > 2,
                                isCurrent: loadingState == .generatingSpeech,
                                isCompact: true
                            )
                        }
                    }
                    
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: FlowTaleColor.accent))
                        .scaleEffect(y: 0.8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FlowTaleColor.background)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .padding(.horizontal, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
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
                        isCompleted ? FlowTaleColor.accent :
                        isCurrent ? FlowTaleColor.accent.opacity(0.3) :
                        FlowTaleColor.secondary.opacity(0.2)
                    )
                    .frame(width: 24, height: 24)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.flowTaleBodyXSmall())
                        .foregroundColor(.white)
                } else if isCurrent {
                    ProgressView()
                        .scaleEffect(0.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: FlowTaleColor.accent))
                } else {
                    Image(systemName: icon)
                        .font(.flowTaleBodyXSmall())
                        .foregroundColor(FlowTaleColor.secondary.opacity(0.6))
                }
            }
        } else {
            // Full version with title
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            isCompleted ? FlowTaleColor.accent :
                            isCurrent ? FlowTaleColor.accent.opacity(0.3) :
                            FlowTaleColor.secondary.opacity(0.2)
                        )
                        .frame(width: 40, height: 40)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.flowTaleBodySmall())
                            .foregroundColor(.white)
                    } else if isCurrent {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: FlowTaleColor.accent))
                    } else {
                        Image(systemName: icon)
                            .font(.flowTaleBodySmall())
                            .foregroundColor(FlowTaleColor.secondary.opacity(0.6))
                    }
                }
                
                Text(title)
                    .font(.flowTaleSecondaryHeader())
                    .foregroundColor(
                        isCompleted || isCurrent ? FlowTaleColor.primary : FlowTaleColor.secondary
                    )
            }
        }
    }
}
