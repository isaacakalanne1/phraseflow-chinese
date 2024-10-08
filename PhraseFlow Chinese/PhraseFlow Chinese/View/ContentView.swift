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
    @State private var showSettings = false // Control for showing settings sheet

    var body: some View {

        let userInput: Binding<String> = .init {
            store.state.userInput
        } set: { newValue in
            store.dispatch(.updateUserInput(newValue))
        }

        VStack(spacing: 20) {
            if store.state.sentences.isEmpty {
                Button("Generate new chapter") {
                    store.dispatch(.generateNewChapter)
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else if let currentSentence = store.state.currentSentence, !store.state.dictionary.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Text(store.state.currentDefinition?.definition ?? "")
                        .font(.body)
                        .opacity(store.state.viewState == .revealAnswer ? 1 : 0)

                    let columns = Array(repeating: GridItem(.fixed(40),
                                                            spacing: 0),
                                        count: 7)
                    LazyVGrid(columns: columns,
                              spacing: 10) {
                        ForEach(Array(currentSentence.mandarin.enumerated()), id: \.offset) { index, element in
                            let character = currentSentence.mandarin[index]
                            VStack {
                                Text("Pinyin here")
                                    .font(.footnote)
                                    .opacity(store.state.viewState == .revealAnswer ? 1 : 0)
                                Text(String(character))
                                    .font(.largeTitle)
                                    .opacity(store.state.practiceMode != .listening ? 1 : store.state.viewState == .revealAnswer ? 1 : 0)
                            }
                            .onTapGesture {
                                if let word = currentSentence.mandarin[index] {
                                    store.dispatch(.defineCharacter(String(word)))
                                }
                            }
                        }
                    }

                    Text(currentSentence.english)
                        .font(.title3)
                        .foregroundColor(.gray)
                        .opacity(store.state.viewState == .revealAnswer ? 1 : 0)
                }
                .padding(.horizontal)

                Text(store.state.answerState == .correct ? "✅ Correct!" : "❌ Incorrect, try again")
                    .foregroundColor(store.state.answerState == .correct ? .green : .red)
                    .padding(.vertical, 10)
                    .opacity(store.state.viewState == .revealAnswer && store.state.practiceMode == .writing ? 1 : 0)

                Spacer()

                // User input and interaction buttons (Check, Next)
                VStack(spacing: 20) {
                    if store.state.practiceMode == .writing {
                        TextField("Enter the Chinese text", text: userInput)
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
                                isTextFieldFocused = store.state.practiceMode == .writing
                                store.dispatch(.goToNextSentence)
                                if store.state.practiceMode == .listening {
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
                                store.dispatch(.submitAnswer)
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
}


#Preview {
    ContentView()
}
