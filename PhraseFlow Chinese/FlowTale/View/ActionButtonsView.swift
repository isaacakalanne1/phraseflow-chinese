//
//  ActionButtonsView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ActionButtonsView: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter

    var body: some View {

        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ActionButton(systemImage: .list) {
                    store.dispatch(.playSound(.actionButtonPress))
                    store.dispatch(.updateShowingStoryListView(isShowing: true))
                }

                divider

                ActionButton(systemImage: .book) {
                    store.dispatch(.playSound(.actionButtonPress))
                    store.dispatch(.updateShowingStudyView(isShowing: true))
                }

                divider

                ActionButton(systemImage: .chartBar) {
                    store.dispatch(.playSound(.actionButtonPress))
                    store.dispatch(.updateShowingDefinitionsChartView(isShowing: true))
                }

                divider

                ActionButton(systemImage: .heart) {
                    store.dispatch(.playSound(.actionButtonPress))
                    store.dispatch(.setSubscriptionSheetShowing(true))
                }

                divider

                ActionButton(systemImage: .gear) {
                    store.dispatch(.playSound(.actionButtonPress))
                    store.dispatch(.updateShowingSettings(isShowing: true))
                }
            }
        }
    }

    @ViewBuilder
    var divider: some View {
        Divider()
            .frame(height: 30)
    }
}
