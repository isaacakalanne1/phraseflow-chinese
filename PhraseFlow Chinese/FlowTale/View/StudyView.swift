//
//  StudyView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var store: FlowTaleStore

    var studyWords: [Definition] {
        store.state.definitionState.definitions
            .filter({
                $0.language == store.state.storyState.currentStory?.language
            })
    }

    var specificWord: Definition? = nil
    var isWordDefinitionView: Bool {
        specificWord != nil
    }
    @State var index: Int = 0
    @State var isDefinitionShown: Bool = false

    var currentDefinition: Definition? {
        studyWords[safe: index]
    }

    var body: some View {
        let displayedDefinition = specificWord ?? currentDefinition
        Group {
            if let definition = displayedDefinition {
                VStack(alignment: .leading) {
                    Text("Word")
                        .greyBackground()
                    ZStack {
                        Text(definition.timestampData.word)
                            .font(.system(size: 40, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Spacer()
                            Button {
                                store.dispatch(.playStudyWord(definition))
                            } label: {
                                SystemImageView(.speaker)
                            }
                        }
                    }
                    Text("Sentence")
                        .greyBackground()
                    Text(definition.sentence.translation)
                        .font(.system(size: 30, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Translation")
                        .greyBackground()
                    if isWordDefinitionView || isDefinitionShown {
                        Text(definition.sentence.original)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("Tap Reveal to show")
                    }
                    Text("Definition")
                        .greyBackground()
                    if isWordDefinitionView || isDefinitionShown {
                        ScrollView(.vertical) {
                            Text(definition.definition)
                                .frame(maxWidth: .infinity,
                                       maxHeight: .infinity,
                                       alignment: .topLeading)
                        }
                    } else {
                        Text("Tap Reveal to show")
                        Spacer()
                    }

                    HStack {
                        Button("Previous") {
                            if index - 1 < 0 {
                                index = studyWords.count - 1
                            } else {
                                index -= 1
                            }
                            isDefinitionShown = false
                        }
                        .padding()
                        .background(FlowTaleColor.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        if !isWordDefinitionView {
                            if isDefinitionShown {
                                Button("Next") {
                                    goToNextDefinition()
                                }
                                .padding()
                                .background(FlowTaleColor.accent)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            } else {
                                Button("Reveal") {
                                    store.dispatch(.playStudyWord(definition))
                                    isDefinitionShown = true
                                }
                                .padding()
                                .background(FlowTaleColor.accent)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Text("No saved words\nTap a word to study")
            }
        }
        .onAppear {
            if !isWordDefinitionView {
                index = 0
                isDefinitionShown = false
            }
        }
        .padding()
    }

    func goToNextDefinition() {
        isDefinitionShown = false
        index = (index + 1) % studyWords.count
        if let definition = currentDefinition {
            store.dispatch(.updateStudiedWord(definition))
        }
    }
}
