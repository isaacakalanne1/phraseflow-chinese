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
    @State private var showStoryListView = false

    var body: some View {

        let isShowingCreateStoryScreen: Binding<Bool> = .init {
            store.state.isShowingCreateStoryScreen
        } set: { newValue in
            store.dispatch(.updateShowingCreateStoryScreen(isShowing: newValue))
        }

        let isShowingSettingsScreen: Binding<Bool> = .init {
            store.state.isShowingSettingsScreen
        } set: { newValue in
            store.dispatch(.updateShowingSettings(isShowing: newValue))
        }

        let isShowingStoryListView: Binding<Bool> = .init {
            store.state.isShowingStoryListView
        } set: { newValue in
            store.dispatch(.updateShowingStoryListView(isShowing: newValue))
        }

        VStack(spacing: 10) {
            if store.state.currentStory == nil {
                Button("Create Story") {
                    store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else if let currentSentence = store.state.currentSentence {
                ScrollView(.vertical) {
                    Text(store.state.currentDefinition?.definition ?? "")
                        .font(.body)
                        .padding(.top)
                }
                .frame(height: 200)

                let columns = Array(repeating: GridItem(.fixed(40), spacing: 0), count: 7)
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(currentSentence.mandarin.enumerated()), id: \.offset) { index, element in
                        let character = currentSentence.mandarin[index]
                        let pinyin = currentSentence.pinyin.count > index ? currentSentence.pinyin[index] : ""
                        let isSelectedWord = index >= store.state.selectedWordStartIndex && index < store.state.selectedWordEndIndex
                        VStack {
                            Text(character == pinyin ? "" : pinyin)
                                .font(.footnote)
                                .foregroundStyle(isSelectedWord ? Color.green : Color.primary)
                                .opacity(store.state.isShowingPinyin ? 1 : 0)
                            Text(character)
                                .font(.largeTitle)
                                .foregroundStyle(isSelectedWord ? Color.green : Color.primary)
                                .opacity(store.state.isShowingMandarin ? 1 : 0)
                        }
                        .onTapGesture {
                            for entry in store.state.timestampData {
                                    let wordStart = entry.textOffset
                                    let wordEnd = entry.textOffset + entry.wordLength
                                    if index >= wordStart && index < wordEnd {
                                        store.dispatch(.updateSelectedWordIndices(startIndex: wordStart, endIndex: wordEnd))
                                        store.dispatch(.defineCharacter(entry.word))
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

                ScrollView(.horizontal) {
                    HStack {
                        Button(action: {
                            store.dispatch(.goToPreviousSentence)
                        }) {
                            Image(systemName: "arrow.left.circle")
                        }

                        Button(action: {
                            if let sentence = store.state.currentSentence {
                                store.dispatch(.synthesizeAudio(sentence))
                            }
                        }) {
                            Image(systemName: "play.circle.fill")
                        }

                        Button(action: {
                            store.dispatch(.goToNextSentence)
                        }) {
                            Image(systemName: "arrow.right.circle")
                        }

                        Button(action: {
                            store.dispatch(.updateShowPinyin(!store.state.isShowingPinyin))
                        }) {
                            Image(systemName: store.state.isShowingPinyin ? "s.circle.fill" : "strikethrough")
                                .frame(width: 50, height: 50)
                        }

                        Button {
                            store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
                        } label: {
                            Image(systemName: "plus.circle")
                        }

                        Button {
                            store.dispatch(.updateShowingStoryListView(isShowing: true))
                        } label: {
                            Image(systemName: "list.bullet.circle.fill")
                        }

                        Button(action: {
                            store.dispatch(.updateShowingSettings(isShowing: true))
                        }) {
                            Image(systemName: "gearshape.circle")
                        }
                    }
                }
                .font(.system(size: 50))
                .padding(.horizontal)
            }
        }
        .background(Color.white)
        .padding(10)
        .sheet(isPresented: isShowingSettingsScreen) {
            SettingsView()
        }
        .sheet(isPresented: isShowingCreateStoryScreen) {
            CreateStoryView()
        }
        .sheet(isPresented: isShowingStoryListView) {
            StoryListView()
        }
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onEnded { value in
            let horizontalAmount = value.translation.width
            let verticalAmount = value.translation.height

            if horizontalAmount > 50 {
                store.dispatch(.goToPreviousSentence)
            } else if horizontalAmount < -50 {
                store.dispatch(.goToNextSentence)
            }
        })
    }
}

#Preview {
    ContentView()
}
