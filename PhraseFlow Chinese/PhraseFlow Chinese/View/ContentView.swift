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
    @State private var showPinyinAndEnglish = false // Control when to show Pinyin and English
    @State private var isCheckButtonVisible = true  // Control the visibility of the "Check" button
    @State private var selectedMode: Mode = .defaultMode // Track the selected mode

    var body: some View {
        VStack(spacing: 10) { // Reduced spacing to 10
            // Mode selection buttons at the top
            HStack(spacing: 10) {
                modeButton("Default", mode: .defaultMode)
                modeButton("Reading", mode: .readingMode)
                modeButton("Listening", mode: .listeningMode)
            }
            .padding(.vertical, 10)
            .background(GeometryReader { geometry in
                modeHighlightingBackground(width: geometry.size.width / 3)
            })

            Spacer()

            if let currentPhrase = viewModel.currentPhrase {
                // Display Mandarin text
                Text(currentPhrase.mandarin)
                    .font(.largeTitle)
                    .padding()
                    .opacity(selectedMode != .listeningMode ? 1 : viewModel.showCorrectText ? 1 : 0)

                // Pinyin text without fading animation
                Text(currentPhrase.pinyin)
                    .font(.title2)
                    .padding(.bottom)
                    .opacity(showPinyinAndEnglish ? 1 : 0) // No animation here, only opacity toggle

                // English text without fading animation
                Text(currentPhrase.english)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                    .opacity(showPinyinAndEnglish ? 1 : 0) // No animation here, only opacity toggle

                // Conditionally show Play Button and TextField based on the selected mode
                Button(action: {
                    viewModel.playTextToSpeech()
                }) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 50))
                        .padding()
                }
                .opacity(selectedMode != .readingMode ? 1 : viewModel.showCorrectText ? 1 : 0)

                // User Input TextField only for Default and Reading Modes
                TextField("Enter the Chinese text", text: $viewModel.userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        viewModel.validateInput()
                        showPinyinAndEnglish = true
                        isCheckButtonVisible = false
                    }
                    .opacity(selectedMode == .listeningMode ? 0 : 1)

                // Feedback for user input validation
                Group {
                    if viewModel.isCorrect {
                        Text("✅ Correct!")
                            .foregroundColor(.green)
                            .opacity(selectedMode == .listeningMode ? 0 : 1)
                    } else {
                        Text("The correct answer is \(currentPhrase.mandarin)")
                            .foregroundColor(.red)
                            .opacity(selectedMode == .listeningMode ? 0 : 1)
                    }
                }
                .opacity(viewModel.showCorrectText ? 1 : 0)

                if viewModel.showCorrectText {
                    // Next Button
                    Button(action: {
                        viewModel.loadNextPhrase()
                        showPinyinAndEnglish = false
                        isCheckButtonVisible = true
                    }) {
                        Text("Next")
                    }
                    .padding()
                } else {
                    Button(action: {
                        viewModel.validateInput()
                        showPinyinAndEnglish = true
                        isCheckButtonVisible = false
                    }) {
                        Text("Check")
                    }
                    .padding()
                    .opacity(isCheckButtonVisible ? 1 : 0)
                }
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
                .font(.headline)
                .foregroundColor(selectedMode == mode ? .white : .primary)
                .frame(maxWidth: .infinity)
        }
    }

    // Highlighting background for the selected mode button
    @ViewBuilder
    func modeHighlightingBackground(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue)
            .frame(width: width) // Adjust width and height for aesthetics
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
