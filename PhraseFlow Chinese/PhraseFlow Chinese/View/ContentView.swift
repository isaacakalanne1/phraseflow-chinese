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
            switch store.state.viewState {
            case .loading:
                Text("Writing new chapter...")
                    .font(.body)
            case .failedToGenerateStory:
                Text("Failed to generate story")
                    .font(.body)
                Button("Retry") {
                    store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            case .failedToGenerateChapter:
                Text("Failed to generate chapter")
                    .font(.body)
                Button("Retry") {
                    if let story = store.state.currentStory {
                        store.dispatch(.generateNewPassage(story: story))
                    }
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            case .normal:
                if store.state.currentStory == nil {
                    Button("Create Story") {
                        store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
                    }
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else if let story = store.state.currentStory,
                          let chapter = store.state.currentChapter,
                          let currentSentence = store.state.currentSentence {
                    ScrollView(.vertical) {
                        Text(store.state.currentDefinition?.definition ?? "")
                            .font(.body)
                            .padding(.top)
                    }
                    .frame(height: 200)

                    ScrollView(.vertical) {
                        Text(currentSentence.english)
                            .font(.title3)
                            .foregroundColor(.gray)
                            .opacity(store.state.isShowingEnglish ? 1 : 0)
                    }
                    .frame(height: 100)

                    ScrollView(.vertical) {
                        ForEach(Array(chapter.sentences.enumerated()), id: \.offset) { index, sentence in
                            let columns = Array(repeating: GridItem(.flexible(minimum: 0, maximum: 40), spacing: 0), count: 7)
                            LazyVGrid(columns: columns, spacing: 0) {
                                ForEach(Array(sentence.mandarin.enumerated()), id: \.offset) { index, element in
                                    let character = sentence.mandarin[index]
                                    let pinyin = sentence.pinyin.count > index ? sentence.pinyin[index] : ""
                                    let isSelectedWord = index >= store.state.selectedWordStartIndex && index < store.state.selectedWordEndIndex
                                    VStack {
                                        Text(character == pinyin ? "" : pinyin)
                                            .font(.footnote)
                                            .foregroundStyle(isSelectedWord ? Color.green : Color.primary)
                                            .opacity(store.state.isShowingPinyin ? 1 : 0)
                                        Text(character)
                                            .font(.title)
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
                            .onTapGesture {
                                store.dispatch(.updateSentenceIndex(index))
                            }
                        }
                    }

                    Spacer()

                    HStack {
                        Button(action: {
                            store.dispatch(.goToPreviousSentence)
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                        }

                        Spacer()

                        Button(action: {
                            if let sentence = store.state.currentSentence {
                                if sentence.audioData != nil {
                                    store.dispatch(.playAudio(time: nil))
                                } else {
                                    store.dispatch(.synthesizeAudio(sentence))
                                }
                            }
                        }) {
                            Image(systemName: "play.circle.fill")
                        }

                        Spacer()

                        Button(action: {
                            store.dispatch(store.state.isLastSentence ? .generateNewPassage(story: story) : .goToNextSentence)
                        }) {
                            Image(systemName: store.state.isLastSentence ? "plus.circle.fill" : "arrow.right.circle.fill")
                        }
                    }
                    .font(.system(size: 50))
                    .padding(.horizontal)

                    HStack {
                        Spacer()
                        Button(action: {
                            store.dispatch(.updateShowPinyin(!store.state.isShowingPinyin))
                        }) {
                            Image(systemName: store.state.isShowingPinyin ? "s.circle.fill" : "strikethrough")
                                .frame(width: 50, height: 50)
                        }

                        Button {
                            store.dispatch(.updateShowingCreateStoryScreen(isShowing: true))
                        } label: {
                            Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                        }

                        Button {
                            store.dispatch(.updateShowingStoryListView(isShowing: true))
                        } label: {
                            Image(systemName: "list.bullet.rectangle.portrait.fill")
                        }

                        Button(action: {
                            store.dispatch(.updateShowingSettings(isShowing: true))
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                        Spacer()
                    }
                    .font(.system(size: 50))
                    .padding(.horizontal)
                }
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
