//
//  PhraseListView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/09/2024.
//

import SwiftUI

struct PhraseListView: View {
    @ObservedObject var viewModel: PhraseViewModel
    let category: PhraseCategory

    @State private var selectedListMode: PhraseListMode = .toLearn // Default to "To Learn"

    var body: some View {
        VStack {
            // List of phrases
            List {
                if selectedListMode == .toLearn {
                    let phrasesToDisplay = category == .short ? viewModel.shortPhrases : viewModel.mediumPhrases
                    ForEach(phrasesToDisplay.filter { !viewModel.allLearningPhrases.contains($0) }, id: \.mandarin) { phrase in
                        Button(phrase.english) {
                            viewModel.moveToLearning(phrase: phrase, category: category)
                        }
                    }
                } else {
                    let learningPhrasesToDisplay = category == .short ? viewModel.learningShortPhrases : viewModel.learningMediumPhrases
                    ForEach(learningPhrasesToDisplay, id: \.mandarin) { phrase in
                        Button(phrase.english) {
                            viewModel.removeFromLearning(phrase: phrase, category: category)
                        }
                    }
                }
            }
            .navigationTitle(categoryTitle)
            .navigationBarTitleDisplayMode(.inline)

            // Buttons to switch between "To Learn" and "Learning" lists
            HStack(spacing: 20) {
                Button(action: {
                    selectedListMode = .toLearn
                }) {
                    Text("To Learn")
                        .foregroundColor(selectedListMode == .toLearn ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedListMode == .toLearn ? Color.accentColor : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }

                Button(action: {
                    selectedListMode = .learning
                }) {
                    Text("Learning")
                        .foregroundColor(selectedListMode == .learning ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedListMode == .learning ? Color.accentColor : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
            }
            .padding()

            Text(selectedListMode == .toLearn ? "Tap phrase to start learning" : "Tap to stop learning phrase")
                .font(.title2)
                .padding(.vertical)
        }
    }

    private var categoryTitle: String {
        switch category {
        case .short: return "Short Phrases"
        case .medium: return "Medium Phrases"
        }
    }
}
