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
            if store.state.allPhrases.isEmpty {
                Button("Add New Phrases") {
                    store.dispatch(.fetchNewPhrases(.short))
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else if let currentPhrase = store.state.currentPhrase, !store.state.dictionary.isEmpty {
                // Display Mandarin text and user interaction buttons
                Spacer()
                VStack(spacing: 10) {
                    Text(store.state.currentDefinition?.definition ?? "")
                        .font(.body)
                        .opacity(store.state.viewState == .revealAnswer ? 1 : 0)

                    let maxColumnCount = 7
                    let columns = Array(repeating: GridItem(.fixed(40), spacing: 0), count: currentPhrase.mandarin.count < maxColumnCount ? currentPhrase.mandarin.count : maxColumnCount)
                    let mandarinCount = currentPhrase.mandarin.count
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(currentPhrase.mandarin.enumerated()), id: \.offset) { index, element in
                            let character = currentPhrase.mandarin[index]
                            let word = currentPhrase.word(atIndex: index)
                            let wordIndex = currentPhrase.splitMandarin?.firstIndex(where: { $0 == word }) ?? 0
                            let splitPinyin = currentPhrase.splitPinyin(dictionary: store.state.dictionary)
                            let pinyin = splitPinyin.count > index ? currentPhrase.splitPinyin(dictionary: store.state.dictionary)[index] : ""
                            VStack {
                                Text(pinyin)
                                    .font(.footnote)
                                    .opacity(store.state.viewState == .revealAnswer ? 1 : 0)
                                Text(String(character))
                                    .font(.largeTitle)
                                    .opacity(store.state.practiceMode != .listening ? 1 : store.state.viewState == .revealAnswer ? 1 : 0)
                            }
                            .onTapGesture {
                                if let word = currentPhrase.word(atIndex: index) {
                                    store.dispatch(.defineCharacter(word))
                                    print(store.state.dictionary[word ?? ""])
                                }
                                let wordIndex = currentPhrase.splitMandarin?.firstIndex(where: { $0 == word })
//                                print(currentPhrase.splitMandarin)
//                                print(currentPhrase.splitPinyin(dictionary: store.state.dictionary))
//                                        let characterIndex = currentPhrase.mandarin.distance(from: currentPhrase.mandarin.startIndex,
//                                                                                             to: index)
//                                        store.dispatch(.playAudioFromIndex(characterIndex))
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
                                store.dispatch(.goToNextPhrase)
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
