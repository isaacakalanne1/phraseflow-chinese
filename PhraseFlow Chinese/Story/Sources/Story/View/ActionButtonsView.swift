//
//  ActionButtonsView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI
import FTColor

struct ActionButtonsView: View {
    @EnvironmentObject var store: StoryStore

    var body: some View {
        var tabs = ContentTab.allCases
        if store.environment.getDefinitions().isEmpty {
            tabs.removeAll(where: { $0 == .progress })
        }
        tabs.removeAll(where: { $0 == .translate })

        return HStack(spacing: 12) {
            ForEach(tabs) { tab in
                let isSelected = store.state.viewState.contentTab == tab
                VStack(spacing: 4) {
                    ActionButton(systemImage: tab.image(isSelected: isSelected),
                                 isSelected: isSelected,
                                 size: 30) {
                        if !isSelected {
                            withAnimation {
                                store.dispatch(.navigationAction(.selectTab(tab, shouldPlaySound: true)))
                            }
                        }
                    }
                    RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                        .frame(width: 40, height: 3)
                        .foregroundStyle(isSelected ? FTColor.accent : Color.clear)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
    }
}
