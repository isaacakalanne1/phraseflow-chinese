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
            HStack(spacing: 20) {
                ActionButton(title: LocalizedString.stories, systemImage: .list) {
                    store.dispatch(.playSound(.mainActionButtonPress))
                    store.dispatch(.updateShowingStoryListView(isShowing: true))
                }

                ActionButton(title: "Study", systemImage: .book) {
                    store.dispatch(.playSound(.mainActionButtonPress))
                    store.dispatch(.updateShowingStudyView(isShowing: true))
                }

                ActionButton(title: "Progress", systemImage: .chartBar) {
                    store.dispatch(.playSound(.mainActionButtonPress))
                    store.dispatch(.updateShowingDefinitionsChartView(isShowing: true))
                }

                ActionButton(title: LocalizedString.subscribe, systemImage: .heart) {
                    store.dispatch(.playSound(.mainActionButtonPress))
                    store.dispatch(.setSubscriptionSheetShowing(true))
                }

                ActionButton(title: LocalizedString.settings, systemImage: .gear) {
                    store.dispatch(.playSound(.mainActionButtonPress))
                    store.dispatch(.updateShowingSettings(isShowing: true))
                }
            }
        }
    }
}
