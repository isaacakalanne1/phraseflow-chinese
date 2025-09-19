//
//  ModerationExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI
import FTColor
import FTFont
import FTStyleKit
import Localization

struct ModerationExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    let customPrompt: String
    let moderationResponse: ModerationResponse?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundColor(FTColor.accent.color)
                    
                    Text(LocalizedString.storyDidNotPassModeration)
                        .font(FTFont.flowTaleHeader())
                        .fontWeight(.bold)
                        .foregroundColor(FTColor.primary.color)
                        .multilineTextAlignment(.center)
                    
                    if !customPrompt.isEmpty {
                        Text(customPrompt)
                            .font(FTFont.flowTaleBodyMedium())
                            .foregroundColor(FTColor.secondary.color)
                            .padding()
                            .background(FTColor.background.color.opacity(0.8))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(FTColor.secondary.color.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                
                // Moderation Results Section
                if let moderationResponse {
                    VStack(spacing: 16) {
                        Text(LocalizedString.whyDidntItPass)
                            .font(FTFont.flowTaleHeader())
                            .fontWeight(.semibold)
                            .foregroundColor(FTColor.primary.color)
                        
                        VStack(spacing: 12) {
                            ForEach(moderationResponse.categoryResults.sorted(by: { !$0.didPass && $1.didPass }), id: \.category) { result in
                                ModerationCategoryCard(result: result)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Information Section
                VStack(spacing: 20) {
                    InfoSection(
                        title: LocalizedString.whatIsModeration,
                        content: LocalizedString.moderationExplanation,
                        icon: "info.circle.fill"
                    )
                    
                    InfoSection(
                        title: LocalizedString.howDoesModerationWork,
                        content: LocalizedString.moderationWorkExplanation,
                        icon: "gearshape.fill"
                    )
                }
                .padding(.horizontal)
                
                // Action Button
                PrimaryButton(title: LocalizedString.okayButton) {
                    dismiss()
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle(LocalizedString.navigationTitleWhy)
        .navigationBarTitleDisplayMode(.inline)
        .background(FTColor.background.color)
    }
}

struct ModerationCategoryCard: View {
    let result: CategoryResult
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with status
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: result.didPass ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(result.didPass ? .green : .red)
                    
                    Text(result.category.name)
                        .font(FTFont.flowTaleBodyMedium())
                        .fontWeight(.semibold)
                        .foregroundColor(FTColor.primary.color)
                }
                
                Spacer()
                
                Text(result.didPass ? "PASSED" : "FAILED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(result.didPass ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(result.didPass ? .green : .red)
                    .cornerRadius(6)
            }
            
            // Visual Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Score: \(result.scorePercentageString)")
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.primary.color)
                    
                    Spacer()
                    
                    Text("Threshold: \(result.thresholdPercentageString)")
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.secondary.color)
                }
                
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(FTColor.secondary.color.opacity(0.2))
                        .frame(height: 12)
                    
                    // Score fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: result.didPass ? 
                                    [.green.opacity(0.7), .green] : 
                                    [.red.opacity(0.7), .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, result.score * UIScreen.main.bounds.width * 0.8), height: 12)
                        .animation(.easeInOut(duration: 0.6), value: result.score)
                    
                    // Threshold indicator (on top)
                    GeometryReader { geometry in
                        let thresholdPosition = result.threshold * geometry.size.width
                        
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 2, height: 12)
                            .offset(x: thresholdPosition - 1)
                    }
                }
                .frame(height: 12)
                
                // Legend
                HStack {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 2, height: 8)
                        Text("Threshold")
                            .font(.caption2)
                            .foregroundColor(FTColor.secondary.color)
                    }
                    
                    Spacer()
                    
                    if !result.didPass {
                        Text("Content exceeded safety threshold")
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(result.didPass ? Color.green.opacity(0.05) : Color.red.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(result.didPass ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(FTColor.accent.color)
                    .font(.title3)
                
                Text(title)
                    .font(FTFont.flowTaleBodyMedium())
                    .fontWeight(.semibold)
                    .foregroundColor(FTColor.primary.color)
                
                Spacer()
            }
            
            Text(content)
                .font(FTFont.flowTaleBodyMedium())
                .foregroundColor(FTColor.secondary.color)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(FTColor.accent.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FTColor.accent.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
