//
//  StudyView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var store: FlowTaleStore

    var studyWords: [StudyWord]

    init(studyWords: [StudyWord]) {
        self.studyWords = studyWords
    }

    @State var index: Int = 0
    @State var isPronounciationShown: Bool = false
    @State var isDefinitionShown: Bool = false

    var currentWord: StudyWord? {
        studyWords[safe: index]
    }

    var isWordDefinitionView: Bool {
        studyWords.count <= 1
    }

    var body: some View {
        Group {
            if let currentWord {
                VStack {
                    ScrollView {
                        wordView(word: currentWord)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollIndicators(.hidden)
                    .onAppear {
                        // Check if device is in silent mode when study view appears
                        store.dispatch(.checkDeviceVolumeZero)
                    }
                    // Navigation controls for browsing words
                    if studyWords.count > 1 {
                        HStack {
                            Button {
                                goToPreviousDefinition(currentWord: currentWord)
                            } label: {
                                Text(LocalizedString.previous)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(FlowTaleColor.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button {
                                if isDefinitionShown {
                                    goToNextDefinition(currentWord: currentWord)
                                } else {
                                    store.dispatch(.studyAction(.playStudyWord(currentWord.timestamp)))
                                    withAnimation {
                                        isPronounciationShown = true
                                        isDefinitionShown = true
                                    }
                                }
                            } label: {
                                Text(isDefinitionShown ? LocalizedString.next : LocalizedString.reveal)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(FlowTaleColor.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                    }
                }
                .onAppear {
                    index = 0
                    updateDefinition(currentWord: currentWord)
                }
            } else {
                // Case 3: No words available
                Text(LocalizedString.noSavedWords + "\n" + LocalizedString.tapWordToStudy)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(LocalizedString.studyNavTitle)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
        .onTapGesture {
            withAnimation {
                if !isPronounciationShown {
                    isPronounciationShown = true
                } else if !isDefinitionShown {
                    isDefinitionShown = true
                } else {
                    isPronounciationShown = false
                    isDefinitionShown = false
                }
            }
        }
    }

    func goToPreviousDefinition(currentWord: StudyWord) {
        if index - 1 < 0 {
            index = studyWords.count - 1
        } else {
            index -= 1
        }
        store.dispatch(.playSound(.previousStudyWord))
        updateDefinition(currentWord: currentWord)
    }

    func goToNextDefinition(currentWord: StudyWord) {
        store.dispatch(.updateStudiedWord(currentWord.timestamp, currentWord.sentence))
        index = (index + 1) % studyWords.count
        store.dispatch(.playSound(.nextStudyWord))
        updateDefinition(currentWord: currentWord)
    }

    func updateDefinition(currentWord: StudyWord) {
        isPronounciationShown = studyWords.count <= 1
        isDefinitionShown = studyWords.count <= 1
        store.dispatch(.studyAction(.updateStudyChapter(nil)))
        store.dispatch(.studyAction(.prepareToPlayStudyWord(currentWord.timestamp, currentWord.sentence)))
        store.dispatch(.studyAction(.pauseStudyAudio))
    }

    /// Returns an AttributedString derived from `baseString`,
    /// with the substring at `characterOffset` (of `length`) in bold.
    ///
    /// - Parameters:
    ///   - baseString: The full sentence/string.
    ///   - characterOffset: The integer start position of the substring you want to highlight.
    ///   - length: How many characters from `characterOffset` should be highlighted.
    /// - Returns: An `AttributedString` with the specified range in bold.
    func boldSubstring(in baseString: String,
                       at characterOffset: Int,
                       length: Int) -> AttributedString?
    {
        // 1) Make sure the substring range is valid in `baseString`
        guard characterOffset >= 0,
              length > 0,
              characterOffset + length <= baseString.count
        else {
            return nil
        }

        // 2) Extract the exact substring we want to highlight
        let startIndex = baseString.index(baseString.startIndex, offsetBy: characterOffset)
        let endIndex   = baseString.index(startIndex, offsetBy: length)
        let substring  = baseString[startIndex..<endIndex]

        // 3) Convert the entire base string to an AttributedString
        var attributed = AttributedString(baseString)

        // 4) Search for that substring inside the attributed string
        //    (This finds the first occurrence, if multiple exist)
        if let rangeInAttributed = attributed.range(of: String(substring)) {
            // 5) Bold the found range
            attributed[rangeInAttributed].font = .system(size: 30, weight: .bold)
        }

        return attributed
    }

    func wordView(word: StudyWord) -> some View {

        // Calculate character count for highlighting
        var characterCount: Int? = nil
        for data in word.sentence.wordTimestamps {
            if data == word.timestamp {
                if characterCount == nil {
                    characterCount = 0
                }
                break
            } else {
                if characterCount == nil {
                    characterCount = 0
                }
                characterCount? += data.word.count
            }
        }
        
        let baseString = word.sentence.translation

        return VStack(alignment: .leading) {
            ZStack {
                Text(word.timestamp.word)
                    .font(.system(size: 60, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Spacer()
                    Button {
                        store.dispatch(.studyAction(.playStudyWord(word.timestamp)))
                    } label: {
                        SystemImageView(.speaker)
                    }
                }
            }
            Text(LocalizedString.studyPronunciationLabel)
                .greyBackground()
            VStack {
                Text(LocalizedString.studyPronunciationPrefix + (word.timestamp.definition?.detail.pronunciation ?? ""))
                    .font(.system(size: 20, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scaleEffect(x: 1, y: isWordDefinitionView || isPronounciationShown ? 1 : 0, anchor: .top)
            .opacity(isWordDefinitionView || isPronounciationShown ? 1 : 0)
            Text(LocalizedString.definition)
                .greyBackground()
            Group {
                Text(LocalizedString.studyDefinitionPrefix + (word.timestamp.definition?.detail.definition ?? ""))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 20, weight: .light))
                Divider()
                Text(LocalizedString.studyContextPrefix + (word.timestamp.definition?.detail.definitionInContextOfSentence ?? ""))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
                    .font(.system(size: 20, weight: .light))
            }
            .opacity(isWordDefinitionView || isDefinitionShown ? 1 : 0)
            .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
            Text(LocalizedString.sentence)
                .greyBackground()
            HStack {
                if let count = characterCount,
                   count >= 0,
                   count + word.timestamp.word.count <= baseString.count,
                   let highlighted = boldSubstring(in: baseString, at: count, length: word.timestamp.word.count) {
                    // In SwiftUI, just show it:
                    Text(highlighted)
                        .font(.system(size: 30, weight: .light))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(word.sentence.translation)
                        .font(.system(size: 30, weight: .light))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button {
                    if store.state.studyState.isAudioPlaying {
                        store.dispatch(.studyAction(.pauseStudyAudio))
                    } else {
                        if let startWord = word.sentence.wordTimestamps.first,
                           let endWord = word.sentence.wordTimestamps.last {
                            store.dispatch(.studyAction(.playStudySentence(startWord: startWord, endWord: endWord)))
                        }
                    }
                } label: {
                    SystemImageView(store.state.studyState.isAudioPlaying ? .stop : .play)
                }
            }
            Text(LocalizedString.translation)
                .greyBackground()
            Text(word.sentence.original)
                .font(.system(size: 20, weight: .light))
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isWordDefinitionView || isDefinitionShown ? 1 : 0)
                .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
        }
    }
}
