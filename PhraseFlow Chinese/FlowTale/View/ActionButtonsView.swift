//
//  ActionButtonsView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ActionButtonsView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        var tabs = ContentTab.allCases
        if store.state.definitionState.definitions.isEmpty {
            tabs.removeAll(where: { $0 == .progress })
        }

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
                        .foregroundStyle(isSelected ? FlowTaleColor.accent : Color.clear)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
    }
}
