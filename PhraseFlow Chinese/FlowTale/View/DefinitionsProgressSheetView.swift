//
//  DefinitionsProgressSheetView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import SwiftUI

struct DefinitionsProgressSheetView: View {
    @EnvironmentObject var store: FlowTaleStore
    @State var selectedTab = 0

    var body: some View {
        let language = store.state.storyState.currentStory?.language
        let definitions = store.state.definitionState.studyDefinitions(language: language)
        let filteredDefinitions = removeDuplicates(from: definitions)

        TabView(selection: $selectedTab) {
            sheetContent(isCreations: true,
                         definitions: filteredDefinitions)
            .tabItem {
                Label(LocalizedString.saved, systemImage: "folder.fill")
            }
            .tag(0)

            sheetContent(isCreations: false,
                         definitions: filteredDefinitions.filter({ !$0.studiedDates.isEmpty }))
            .tabItem {
                Label(LocalizedString.studied, systemImage: "eyeglasses")
            }
            .tag(1)
        }
        .onChange(of: selectedTab) {
            // Debug - print the state of definitions to diagnose the issue
            print("Total definitions: \(definitions.count)")
            print("Definitions with hasBeenSeen=true: \(definitions.filter { $0.hasBeenSeen }.count)")
            store.dispatch(.playSound(.actionButtonPress))
        }
    }

    @ViewBuilder
    func sheetContent(isCreations: Bool, definitions: [Definition]) -> some View {
        NavigationView {
            VStack {
                DefinitionsChartView(definitions: definitions, isCreations: isCreations)
                    .frame(height: 300)
                List {
                    Section {
                        ForEach(definitions, id: \.self) { definition in
                            NavigationLink {
                                StudyView(specificWord: definition)
                            } label: {
                                Text(definition.timestampData.word)
                                    .fontWeight(.light)
                                    .foregroundStyle(FlowTaleColor.primary)
                            }
                        }
                    } header: {
                        Text(LocalizedString.allWords)
                    }
                }
                .frame(maxHeight: .infinity)
                .navigationTitle(isCreations ?
                                 LocalizedString.wordsSaved("\(definitions.count)") :
                                    LocalizedString.wordsStudied("\(definitions.reduce(0, { $0 + $1.studiedDates.count }))"))
                .navigationBarTitleDisplayMode(.inline)
                .background(FlowTaleColor.background)
                .scrollContentBackground(.hidden)
            }
            .background(FlowTaleColor.background)
        }
    }

    func removeDuplicates(from definitions: [Definition]) -> [Definition] {
        var filteredDefinitions: [Definition] = []
        for def in definitions {
            if !filteredDefinitions.contains(where: { $0.timestampData.word == def.timestampData.word }) {
                filteredDefinitions.append(def)
            }
        }
        return filteredDefinitions
    }
}
