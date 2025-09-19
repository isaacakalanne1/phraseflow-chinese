//
//  UserLimitView.swift
//  UserLimit
//
//  Created by Isaac Akalanne on 13/09/2025.
//

import SwiftUI
import FTColor
import Localization
import FTStyleKit

struct UserLimitView: View {
    let remainingCharacters: Int
    let totalLimit: Int
    let isSubscribedUser: Bool
    let timeUntilReset: String?
    
    var body: some View {
        SectionView(
            title: (isSubscribedUser == true) ? "DAILY USAGE" : "FREE TRIAL USAGE", // TODO: Localize
            content: {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text((isSubscribedUser) ? "Characters Remaining Today" : "Characters Remaining") // TODO: Localize
                                .font(.caption)
                                .foregroundColor(FTColor.secondary.color)
                            Text("\(remainingCharacters)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(remainingCharacters > 0 ? FTColor.primary.color : .red)
                        }
                        
                        Spacer()
                        
                        if isSubscribedUser,
                           let timeUntilReset = timeUntilReset {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(LocalizedString.resetsInLabel)
                                    .font(.caption)
                                    .foregroundColor(FTColor.secondary.color)
                                
                                Text(timeUntilReset)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(FTColor.primary.color)
                            }
                        }
                    }
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text(LocalizedString.usageProgress)
                                .font(.caption)
                                .foregroundColor(FTColor.secondary.color)
                            Spacer()
                            Text("\(remainingCharacters) of \(totalLimit)") // TODO: Localize
                                .font(.caption)
                                .foregroundColor(FTColor.secondary.color)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(FTColor.secondary.color.opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                let width = geometry.size.width * CGFloat(remainingCharacters) / CGFloat(totalLimit)
                                Rectangle()
                                    .fill(remainingCharacters > 0 ? FTColor.primary.color : .red)
                                    .frame(width: width > 0 ? width : 0, height: 6)
                                    .cornerRadius(3)
                                    .animation(.easeInOut(duration: 0.3), value: remainingCharacters)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        )
    }
}
