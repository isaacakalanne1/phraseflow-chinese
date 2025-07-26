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
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(FTColor.accent)
                
                Text(LocalizedString.dailyLimitReached)
                    .font(FTFont.flowTaleHeadline())
                    .foregroundColor(FTColor.primary)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedString.dailyLimitExplanation)
                    .font(FTFont.flowTaleBody())
                    .foregroundColor(FTColor.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("OK")
                        .font(FTFont.flowTaleBody())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(FTColor.accent)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Daily Limit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(FTColor.accent)
                }
            }
        }
        .background(FTColor.background)
    }
}