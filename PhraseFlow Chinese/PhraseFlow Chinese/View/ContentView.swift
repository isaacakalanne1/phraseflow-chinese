//
//  ContentView.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: FastChineseStore

    @FocusState var isTextFieldFocused
    @State private var showSettings = false

    var body: some View {

        VStack(spacing: 10) {
            if store.state.sentences.isEmpty {
                Button("Generate new story") {
                    store.dispatch(.generateNewChapter)
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else if let currentSentence = store.state.currentSentence {
                Spacer()
                Text(store.state.currentDefinition?.definition ?? "")
                    .font(.body)

                let columns = Array(repeating: GridItem(.fixed(40),
                                                        spacing: 0),
                                    count: 7)
                LazyVGrid(columns: columns,
                          spacing: 10) {
                    ForEach(Array(currentSentence.mandarin.enumerated()), id: \.offset) { index, element in
                        let character = currentSentence.mandarin[index]
                        let pinyin = currentSentence.pinyin.count > index ? currentSentence.pinyin[index] : ""
                        VStack {
                            Text(pinyin)
                                .font(.footnote)
                                .opacity(store.state.isShowingPinyin ? 1 : 0)
                            Text(character)
                                .font(.largeTitle)
                                .opacity(store.state.isShowingMandarin ? 1 : 0)
                        }
                        .onTapGesture {
//                            store.dispatch(.defineCharacter(character))
                            for entry in store.state.timestampData {
                                    let wordStart = entry.textOffset
                                    let wordEnd = entry.textOffset + entry.wordLength
                                    if index >= wordStart && index < wordEnd {
                                        let resultEntry = (word: entry.word, time: entry.time)
                                        print("Result entry is \(resultEntry)")
                                        store.dispatch(.playAudio(time: entry.time))
                                    }
                                }
                        }
                    }
                }

                Text(currentSentence.english)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .opacity(store.state.isShowingEnglish ? 1 : 0)

                Spacer()

                HStack {
                    Button {
                        isTextFieldFocused = false
                        showSettings = true
                    } label: {
                        Image(systemName: "list.bullet.circle.fill")
                    }

                    Button(action: {
                        if let sentence = store.state.currentSentence {
                            store.dispatch(.synthesizeAudio(sentence))
                        }
                    }) {
                        Image(systemName: "play.circle")
                    }

                    Button(action: {
                        store.dispatch(.goToNextSentence)
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                }
                .font(.system(size: 50))
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
