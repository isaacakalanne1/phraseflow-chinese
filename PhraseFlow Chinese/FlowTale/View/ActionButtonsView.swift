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
                    ActionButton(systemImage: tab.image(isFilled: isSelected),
                                 size: isSelected ? 42 : 35) {
                        if !isSelected {
                            withAnimation {
                                store.dispatch(.selectTab(tab, shouldPlaySound: true))
                            }
                        }
                    }
                    if tab.id != tabs.last?.id {
                        Divider()
                            .frame(height: 30)
                    }
                }
            }
        }
    }
}
