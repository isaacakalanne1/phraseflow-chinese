//
//  MainContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI

public struct MainContentView: View {
    public var body: some View {
        VStack {
            DisplayedContentView()
            TabBarView()
        }
    }
}

#Preview {
    MainContentView()
}
