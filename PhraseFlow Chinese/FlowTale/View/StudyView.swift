//
//  StudyView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var store: FlowTaleStore

    @State var studyWords: [Definition] = []
    @State var index: Int = 0
    @State var isDefinitionShown: Bool = false

    var currentDefinition: Definition? {
        studyWords[safe: index]
    }

    var storyOfDefinition: Story? {
        store.state.storyState.savedStories.first(where: { $0.id == currentDefinition?.timestampData.storyId })
    }

    var body: some View {
        Group {
            if let definition = currentDefinition {
                VStack {
                    ZStack {
                        Text(definition.timestampData.word)
                            .font(.system(size: 40, weight: .bold))
                        HStack {
                            Spacer()
                            Button {
                                store.dispatch(.playStudyWord(definition))
                            } label: {
                                SystemImageView(.speaker)
                            }
                            .padding(.trailing)
                        }
                    }
                    Text(definition.sentence.translation)
                        .font(.system(size: 30, weight: .regular))
                    if isDefinitionShown {
                        Text(definition.definition)
                            .padding(.horizontal)
                        Button("Next") {
                            goToNextDefinition()
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    } else {
                        Button("Reveal") {
                            store.dispatch(.playStudyWord(definition))
                            isDefinitionShown = true
                        }
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .onAppear {
            studyWords = Array(store.state.definitionState.definitions
                .shuffled()
                .filter({
                    $0.language == store.state.storyState.currentStory?.language &&
                    $0.timestampData.storyId == store.state.storyState.currentStory?.id
                })
                .prefix(10))
            index = 0
            isDefinitionShown = false
        }
    }

    func goToNextDefinition() {
        isDefinitionShown = false
        index += 1 % 10
    }
}
