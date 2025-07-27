//
//  TabBarView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI
import Story
import FTColor

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
                VStack(spacing: 4) {
                    ActionButton(
                        systemImage: tab.image(isSelected: store.state.contentTab == tab),
                        isSelected: store.state.contentTab == tab,
                        size: 30
                    ) {
                        if store.state.contentTab != tab {
                            withAnimation {
                                store.dispatch(.selectTab(tab, shouldPlaySound: true))
                            }
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(store.state.contentTab == tab ? FTColor.accent : Color.clear)
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
