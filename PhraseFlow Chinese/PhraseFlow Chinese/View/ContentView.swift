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

struct ContentView: View {
    @StateObject private var viewModel = PhraseViewModel()
    @FocusState var isTextFieldFocused
    @State private var showPinyinAndEnglish = false // Control when to show Pinyin and English
    @State private var isCheckButtonVisible = true  // Control the visibility of the "Check" button
    @State private var selectedMode: Mode = .defaultMode // Track the selected mode

    var body: some View {
        VStack(spacing: 20) { // Use spacing to separate elements neatly

            // Display the Mandarin text and Play button together
            if let currentPhrase = viewModel.currentPhrase {
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
                                viewModel.loadNextPhrase()
                                showPinyinAndEnglish = false
                                isCheckButtonVisible = true
                            }) {
                                Text("Next")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            Button(action: {
                                viewModel.validateInput()
                                showPinyinAndEnglish = true
                                isCheckButtonVisible = false
                            }) {
                                Text("Check")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
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
                }
                .padding(.horizontal)
            } else {
                Text("Loading phrases...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear(perform: viewModel.loadPhrases)
        .padding(10)
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
                .background(selectedMode == mode ? Color.blue : Color.gray.opacity(0.3))
                .cornerRadius(10)
        }
    }

    // Highlighting background for the selected mode button
    @ViewBuilder
    func modeHighlightingBackground(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue)
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
