//
//  ContentView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PhraseViewModel()
    @FocusState var isTextFieldFocused
    @State private var showPinyinAndEnglish = false // Control when to show Pinyin and English
    @State private var isCheckButtonVisible = true  // Control the visibility of the "Check" button
    @State private var selectedMode: Mode = .readingMode // Track the selected mode
    @State private var showSettings = false // Control for showing settings sheet

    var body: some View {
        VStack(spacing: 20) {
            // Display content or loading
            if viewModel.phrases.isEmpty {
                Text("Loading phrases...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.allLearningPhrases.isEmpty {
                Button("Get Started") {
                    showSettings = true
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else if let currentPhrase = viewModel.currentPhrase {
                // Display Mandarin text and user interaction buttons
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

                Text(viewModel.isCorrect ? "✅ Correct!" : "❌ Incorrect, try again")
                    .foregroundColor(viewModel.isCorrect ? .green : .red)
                    .padding(.vertical, 10)
                    .opacity(viewModel.showCorrectText && selectedMode == .writingMode ? 1 : 0)

                Spacer()

                // User input and interaction buttons (Check, Next)
                VStack(spacing: 20) {
                    if selectedMode == .writingMode {
                        TextField("Enter the Chinese text", text: $viewModel.userInput)
                            .focused($isTextFieldFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                showPinyinAndEnglish = true
                                isCheckButtonVisible = false
                                viewModel.validateInput()
                                viewModel.playTextToSpeech()
                            }
                    }

                    // Check and Next buttons
                    HStack {
                        Button(action: {
                            viewModel.playTextToSpeech()
                        }) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 50))
                        }
                        if viewModel.showCorrectText {
                            Button(action: {
                                isTextFieldFocused = selectedMode == .writingMode
                                showPinyinAndEnglish = false
                                isCheckButtonVisible = true
                                viewModel.loadNextPhrase()
                                if selectedMode == .listeningMode {
                                    viewModel.playTextToSpeech()
                                }
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
                                showPinyinAndEnglish = true
                                isCheckButtonVisible = false
                                viewModel.validateInput()
                                viewModel.playTextToSpeech()
                            }) {
                                Text("Reveal")
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

                    Button {
                        isTextFieldFocused = false
                        showSettings = true
                    } label: {
                        Text("Settings")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(10)
        .sheet(isPresented: $showSettings) {
            settingsView()
        }
    }

    // Settings view
    @ViewBuilder
    private func settingsView() -> some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()

                Text("Choose Phrases to Learn")
                    .font(.title2)

                NavigationLink(destination: PhraseListView(viewModel: viewModel, category: .short)) {
                    Text("Short")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 100)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }

                NavigationLink(destination: PhraseListView(viewModel: viewModel, category: .medium)) {
                    Text("Medium")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 100)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }

                NavigationLink(destination: PhraseListView(viewModel: viewModel, category: .long)) {
                    Text("Long")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: 100)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                .padding(.bottom)

                Text("Choose Speech Speed")
                    .font(.title2)

                HStack {
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.speechSpeed = .slow
                        }
                    }) {
                        Text("Slow")
                            .font(.body)
                            .foregroundColor(viewModel.speechSpeed == .slow ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.speechSpeed == .slow ? Color.accentColor : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.speechSpeed = .normal
                        }
                    }) {
                        Text("Normal")
                            .font(.body)
                            .foregroundColor(viewModel.speechSpeed == .normal ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.speechSpeed == .normal ? Color.accentColor : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            viewModel.speechSpeed = .fast
                        }
                    }) {
                        Text("Fast")
                            .font(.body)
                            .foregroundColor(viewModel.speechSpeed == .fast ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.speechSpeed == .fast ? Color.accentColor : Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }

                Text("Choose Mode")
                    .font(.title2)

                HStack(spacing: 10) {
                    modeButton("Reading", mode: .readingMode)
                    modeButton("Writing", mode: .writingMode)
                    modeButton("Listening", mode: .listeningMode)
                }

                Text("Settings")
                    .font(.title2.bold())
                    .padding(.vertical)
            }
            .toolbar(.hidden)
            .padding(.horizontal)
        }
    }

    // Mode selection buttons
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
}

#Preview {
    ContentView()
}
