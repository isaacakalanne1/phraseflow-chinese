//
//  ContentView.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PhraseViewModel()
    @State private var showPinyinAndEnglish = false // Control when to show Pinyin and English
    @State private var isCheckButtonVisible = true  // Control the visibility of the "Check" button

    var body: some View {
        VStack(spacing: 10) { // Reduced spacing to 10
            if let currentPhrase = viewModel.currentPhrase {
                // Display Mandarin text
                Text(currentPhrase.mandarin)
                    .font(.largeTitle)
                    .padding()

                // Pinyin text with opacity control
                Text(currentPhrase.pinyin)
                    .font(.title2)
                    .padding(.bottom)
                    .opacity(showPinyinAndEnglish ? 1 : 0) // Opacity based on showPinyinAndEnglish
                    .animation(.easeInOut(duration: 0.5), value: showPinyinAndEnglish)

                // English text with opacity control
                Text(currentPhrase.english)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom)
                    .opacity(showPinyinAndEnglish ? 1 : 0) // Opacity based on showPinyinAndEnglish
                    .animation(.easeInOut(duration: 0.5), value: showPinyinAndEnglish)

                // Play Button
                Button(action: {
                    viewModel.playTextToSpeech()
                }) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 50))
                        .padding()
                }

                // User Input TextField
                TextField("Enter the Chinese text", text: $viewModel.userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Feedback for user input validation
                if viewModel.showCorrectText {
                    if viewModel.isCorrect {
                        Text("✅ Correct!")
                            .foregroundColor(.green)
                    } else {
                        Text("❌ Incorrect, the correct answer is \(currentPhrase.mandarin)")
                            .foregroundColor(.red)
                    }
                }

                // Show Check Button only when it hasn't been tapped yet
                if isCheckButtonVisible {
                    Button(action: {
                        viewModel.validateInput()
                        showPinyinAndEnglish = true // Reveal Pinyin and English after checking
                        isCheckButtonVisible = false // Hide Check Button after it's tapped
                    }) {
                        Text("Check")
                    }
                    .padding()
                }

                // Next Button
                Button(action: {
                    viewModel.loadNextPhrase()
                    showPinyinAndEnglish = false // Reset to hide Pinyin and English for the next phrase
                    isCheckButtonVisible = true  // Reshow Check Button for the next phrase
                }) {
                    Text("Next")
                }
                .padding()
            } else {
                Text("Loading phrases...")
            }
        }
        .onAppear(perform: viewModel.loadPhrases)
    }
}

#Preview {
    ContentView()
}
