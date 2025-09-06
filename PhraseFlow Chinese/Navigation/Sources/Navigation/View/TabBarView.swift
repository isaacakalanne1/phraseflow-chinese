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
        HStack(spacing: 12) {
            ForEach(filteredTabs, id: \.self) { tab in
                let isSelected = store.state.contentTab == tab
                VStack(spacing: 4) {
                    ActionButton(
                        systemImage: tab.image(isSelected: isSelected),
                        isSelected: store.state.contentTab == tab,
                        size: 30
                    ) {
                        if !isSelected {
                            withAnimation {
                                store.dispatch(.selectTab(tab, shouldPlaySound: true))
                            }
                        }
                    }
                    
                    Text(tab.title)
                        .font(FTFont.flowTaleBodyXSmall())
                        .foregroundStyle(isSelected ? FTColor.accent : FTColor.primary)
                    
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(isSelected ? FTColor.accent : Color.clear)
                        .frame(width: 40, height: 3)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
        .background(FTColor.background)
    }
}

#Preview {
    TabBarView()
}
