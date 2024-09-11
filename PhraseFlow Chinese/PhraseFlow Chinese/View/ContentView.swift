//
//  ContentView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FastChineseStore

    @FocusState var isTextFieldFocused
    @State private var selectedMode: Mode = .readingMode // Track the selected mode
    @State private var showSettings = false // Control for showing settings sheet

    var body: some View {
        VStack(spacing: 20) {
            // Display content or loading
            if store.state.allPhrases.isEmpty {
                Text("Loading phrases...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.state.allLearningPhrases.isEmpty {
                Button("Get Started") {
                    showSettings = true
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else if let currentPhrase = store.state.currentPhrase {
                // Display Mandarin text and user interaction buttons
                Spacer()
                VStack(spacing: 10) {
                    Text(currentPhrase.pinyin)
                        .font(.title2)
                        .opacity(store.state.viewState == .revealAnswer ? 1 : 0)

                    HStack {
                        ForEach(Array(currentPhrase.mandarin.indices), id: \.self) { index in
                            let character = currentPhrase.mandarin[index]
                            Text(String(character))
                                .font(.largeTitle)
                                .opacity(selectedMode != .listeningMode ? 1 : store.state.viewState == .revealAnswer ? 1 : 0)
                                .onTapGesture {

                                    let characterIndex = currentPhrase.mandarin.distance(from: currentPhrase.mandarin.startIndex, to: index)
                                    viewModel.playAudio(from: characterIndex)  // Send the index of the selected character
                                    viewModel.fetchAzureCharacterDefinition(character: String(character), phrase: currentPhrase.mandarin) { data in

                                    }
                                }
                        }
                    }

                    Text(currentPhrase.english)
                        .font(.title3)
                        .foregroundColor(.gray)
                        .opacity(store.state.viewState == .revealAnswer ? 1 : 0)
                }
                .padding(.horizontal)

                Text(store.state.answerState == .correct ? "✅ Correct!" : "❌ Incorrect, try again")
                    .foregroundColor(store.state.answerState == .correct ? .green : .red)
                    .padding(.vertical, 10)
                    .opacity(store.state.viewState == .revealAnswer && selectedMode == .writingMode ? 1 : 0)

                Spacer()

                // User input and interaction buttons (Check, Next)
                VStack(spacing: 20) {
                    if selectedMode == .writingMode {
                        TextField("Enter the Chinese text", text: store.state.userInput)
                            .focused($isTextFieldFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                store.dispatch(.submitAnswer)
                                store.dispatch(.playAudio)
                            }
                    }

                    // Check and Next buttons
                    HStack {
                        Button(action: {
                            store.dispatch(.playAudio)
                        }) {
                            Image(systemName: "play.circle")
                                .font(.system(size: 50))
                        }
                        if store.state.viewState == .revealAnswer {
                            Button(action: {
                                isTextFieldFocused = selectedMode == .writingMode
                                store.dispatch(.goToNextPhrase)
                                if selectedMode == .listeningMode {
                                    store.dispatch(.playAudio)
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
                                store.dispatch(.revealAnswer)
                                store.dispatch(.playAudio)
                            }) {
                                Text("Reveal")
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .opacity(store.state.viewState == .revealAnswer ? 1 : 0)
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
            SettingsView()
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
