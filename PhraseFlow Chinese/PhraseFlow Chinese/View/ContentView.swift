//
//  ContentView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

enum Mode {
    case defaultMode
    case readingMode
    case listeningMode
}

enum PhraseListMode {
    case toLearn
    case learning
}

struct ContentView: View {
    @StateObject private var viewModel = PhraseViewModel()
    @FocusState var isTextFieldFocused
    @State private var showPinyinAndEnglish = false // Control when to show Pinyin and English
    @State private var isCheckButtonVisible = true  // Control the visibility of the "Check" button
    @State private var selectedMode: Mode = .defaultMode // Track the selected mode
    @State private var showPhrasePicker = false // Control for showing popover
    @State private var selectedListMode: PhraseListMode = .toLearn // Toggle between To Learn and Learning lists


    var body: some View {
        VStack(spacing: 20) { // Use spacing to separate elements neatly

            // Display the Mandarin text and Play button together
            if viewModel.phrases.isEmpty {
                Text("Loading phrases...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.learningPhrases.isEmpty {
                Button("Choose words to learn") {
                    showPhrasePicker = true
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else if let currentPhrase = viewModel.currentPhrase {
                Spacer()
                VStack(spacing: 10) {
                    Text(currentPhrase.pinyin)
                        .font(.title2)
                        .opacity(showPinyinAndEnglish ? 1 : 0)

                    Text(currentPhrase.mandarin)
                        .font(.largeTitle)
                        .opacity(selectedMode != .listeningMode ? 1 : viewModel.showCorrectText ? 1 : 0)

                    Text(currentPhrase.english)
                        .font(.title3)
                        .foregroundColor(.gray)
                        .opacity(showPinyinAndEnglish ? 1 : 0)
                }
                .padding(.horizontal)

                Group {
                    if viewModel.isCorrect {
                        Text("✅ Correct!")
                            .foregroundColor(.green)
                    } else {
                        Text("❌ Incorrect, try again")
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 10)
                .opacity(viewModel.showCorrectText && selectedMode != .listeningMode ? 1 : 0)

                Spacer()

                // User Input and Interaction Buttons (Check, Next)
                VStack(spacing: 20) {
                    if selectedMode != .listeningMode {
                        TextField("Enter the Chinese text", text: $viewModel.userInput)
                            .focused($isTextFieldFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                viewModel.validateInput()
                                showPinyinAndEnglish = true
                                isCheckButtonVisible = false
                            }
                    }

                    // Check and Next buttons
                    HStack {
                        if selectedMode != .readingMode || (selectedMode == .readingMode && viewModel.showCorrectText) {
                            Button(action: {
                                viewModel.playTextToSpeech()
                            }) {
                                Image(systemName: "play.circle")
                                    .font(.system(size: 50))
                            }
                        }
                        if viewModel.showCorrectText {
                            Button(action: {
                                isTextFieldFocused = false
                                viewModel.loadNextPhrase()
                                showPinyinAndEnglish = false
                                isCheckButtonVisible = true
                            }) {
                                Text("Next")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            Button(action: {
                                isTextFieldFocused = false
                                showPinyinAndEnglish = true
                                isCheckButtonVisible = false
                                viewModel.validateInput()
                                viewModel.playTextToSpeech()
                            }) {
                                Text("Check")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .opacity(isCheckButtonVisible ? 1 : 0)
                        }
                    }

                    // Mode Buttons at the bottom
                    HStack(spacing: 10) {
                        modeButton("Default", mode: .defaultMode)
                        modeButton("Reading", mode: .readingMode)
                        modeButton("Listening", mode: .listeningMode)
                    }

                    Button("Choose words to learn") {
                        showPhrasePicker = true
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                }
                .padding(.horizontal)
            } else {

            }
        }
        .onAppear(perform: viewModel.loadPhrases)
        .padding(10)
        .sheet(isPresented: $showPhrasePicker) {
            phraseSelectionView()
        }
    }

    // Popover Sheet to Select Phrases (Now with a toggle for To Learn and Learning lists)
    @ViewBuilder
    private func phraseSelectionView() -> some View {
        VStack {
            Text(selectedListMode == .toLearn ? "Tap phrases to learn" : "Tap phrases to stop learning")
                .font(.headline)
                .padding()

            // Buttons to toggle between "To Learn" and "Learning" lists
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
            .padding(.horizontal)

            // Display the correct list based on the selected mode
            List {
                if selectedListMode == .toLearn {
                    ForEach(viewModel.toLearnPhrases.filter { !viewModel.learningPhrases.contains($0) }, id: \.mandarin) { phrase in
                        Button(phrase.english) {
                            viewModel.moveToLearning(phrase: phrase)
                        }
                    }
                } else {
                    ForEach(viewModel.learningPhrases, id: \.mandarin) { phrase in
                        Button(phrase.english) {
                            viewModel.removeFromLearning(phrase: phrase) // Remove from Learning
                        }
                    }
                }
            }

            // Done button
            Button("Done") {
                showPhrasePicker = false
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    // Helper function to create mode selection buttons
    func modeButton(_ text: String, mode: Mode) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                selectedMode = mode
            }
        }) {
            Text(text)
                .font(.body)
                .foregroundColor(selectedMode == mode ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedMode == mode ? Color.accentColor : Color.gray.opacity(0.3))
                .cornerRadius(10)
        }
    }

    // Highlighting background for the selected mode button
    @ViewBuilder
    func modeHighlightingBackground(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.accentColor)
            .frame(width: width)
            .offset(x: modeHighlightingOffset(width: width), y: 0)
            .animation(.easeInOut, value: selectedMode)
    }

    // Calculate the offset for the highlighting background based on selected mode
    func modeHighlightingOffset(width: CGFloat) -> CGFloat {
        switch selectedMode {
        case .defaultMode: return 0
        case .readingMode: return width
        case .listeningMode: return width * 2
        }
    }
}

#Preview {
    ContentView()
}
