//
//  DefinitionsProgressSheetView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import SwiftUI

struct DefinitionsProgressSheetView: View {
    @EnvironmentObject var store: FlowTaleStore

    var body: some View {
        let definitions = store.state.definitionState.definitions
            .filter {
                $0.language == store.state.storyState.currentStory?.language
            }

        let filteredDefinitions = removeDuplicates(from: definitions)
            .sorted(by: { $0.creationDate > $1.creationDate })

        if filteredDefinitions.isEmpty {
            Text("No saved words\nTap a word to save")
        } else {
            DefinitionsChartView(definitions: filteredDefinitions)
                .frame(height: 300)
            List {
                Section {
                    ForEach(filteredDefinitions, id: \.self) { definition in
                        NavigationLink {
                            StudyView(studyWords: [definition], isWordDefinitionView: true)
                        } label: {
                            Text(definition.timestampData.word)
                                .fontWeight(.light)
                                .foregroundStyle(FlowTaleColor.primary)
                        }
                    }
                } header: {
                    Text("All Words")
                }
            }
            .frame(maxHeight: .infinity)
            .navigationTitle("Words Learned: \(filteredDefinitions.count)")
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
