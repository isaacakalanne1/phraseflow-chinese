//
//  TabBarView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI
import Story
import FTColor
import FTFont

struct TabBarView: View {
    @EnvironmentObject var store: NavigationStore
    
    private var filteredTabs: [ContentTab] {
        ContentTab.allCases.filter { tab in
            switch tab {
            default:
                return true
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(filteredTabs, id: \.self) { tab in
                let isSelected = store.state.contentTab == tab
                VStack(spacing: 4) {
                    ActionButton(
                        systemImage: tab.image(isSelected: isSelected),
                        isSelected: store.state.contentTab == tab,
                        size: 30
                    ) {
                        if !isSelected {
                            tapAction(tab: tab)
                        }
                    }
                    
                    Text(tab.title)
                        .font(FTFont.bodyXSmall.font)
                        .foregroundStyle(isSelected ? FTColor.accent.color : FTColor.primary.color)
                    
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(isSelected ? FTColor.accent.color : Color.clear)
                        .frame(width: 40, height: 3)
                }
                .frame(maxWidth: .infinity)
                .background(FTColor.background.color)
                .padding(.top, 4)
                .onTapGesture {
                    tapAction(tab: tab)
                }
            }
        }
        .background(FTColor.background.color)
    }
    
    private func tapAction(tab: ContentTab) {
        withAnimation {
            store.dispatch(.selectTab(tab))
        }
    }
}

#Preview {
    TabBarView()
}
