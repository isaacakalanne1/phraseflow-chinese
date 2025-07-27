//
//  ContentView.swift
//  FlowTale
//
//  Created by iakalann on 07/09/2024.
//

import Navigation
import SwiftUI

struct ContentView: View {
    let flowTaleEnvironment: FlowTaleEnvironmentProtocol
    
    var body: some View {
        MainContentView(environment: flowTaleEnvironment.navigationEnvironment)
    }
}

#Preview {
    ContentView(flowTaleEnvironment: FlowTaleEnvironment.mock)
}
