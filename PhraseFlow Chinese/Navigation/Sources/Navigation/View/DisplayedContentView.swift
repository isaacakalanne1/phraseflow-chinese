//
//  DisplayedContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI

struct DisplayedContentView: View {
    @EnvironmentObject var store: NavigationStore
    
    var body: some View {
        PersistentTabContainer()
            .environmentObject(store)
    }
}

#Preview {
    DisplayedContentView()
}
