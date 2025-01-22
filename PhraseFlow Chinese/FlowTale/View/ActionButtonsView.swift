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

        let tabs = ContentTab.allCases

        VStack(alignment: .center) {
            HStack(spacing: 12) {
                ForEach(tabs) { tab in
                    let isSelected = store.state.viewState.contentTab == tab
                    VStack(spacing: 4) {
                        ActionButton(systemImage: tab.image(isSelected: isSelected),
                                     isSelected: isSelected,
                                     size: 35) {
                            if !isSelected {
                                withAnimation {
                                    store.dispatch(.selectTab(tab, shouldPlaySound: true))
                                }
                            }
                        }
                        Rectangle()
                            .frame(width: 35, height: 2)
                            .foregroundStyle(isSelected ? FlowTaleColor.accent : Color.clear)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                }
            }
        }
    }
}
