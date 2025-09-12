//
//  DailyLimitExplanationView.swift
//  UserLimit
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import Localization
import FTColor
import FTFont

public struct DailyLimitExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    private let nextAvailable: String
    private let onDismiss: (() -> Void)?
    
    public init(nextAvailable: String = "", onDismiss: (() -> Void)? = nil) {
        self.nextAvailable = nextAvailable
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(FTColor.accent)
                
                Text(LocalizedString.dailyLimitReached)
                    .font(FTFont.flowTaleHeader())
                    .foregroundColor(FTColor.primary)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedString.dailyLimitExplanation)
                    .font(FTFont.flowTaleBodyMedium())
                    .foregroundColor(FTColor.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if !nextAvailable.isEmpty {
                    Text(LocalizedString.nextAvailableIn(nextAvailable))
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(FTColor.accent)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    onDismiss?()
                    dismiss()
                }) {
                    Text(LocalizedString.ok)
                        .font(FTFont.flowTaleBodyMedium())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(FTColor.accent)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .navigationTitle(LocalizedString.dailyLimit)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.close) {
                        onDismiss?()
                        dismiss()
                    }
                    .foregroundColor(FTColor.accent)
                }
            }
        }
        .background(FTColor.background)
    }
}