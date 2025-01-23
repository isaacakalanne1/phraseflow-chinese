//
//  StudyView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var store: FlowTaleStore

    var studyWords: [Definition] {
        store.state.definitionState.definitions
            .filter({
                $0.language == store.state.storyState.currentStory?.language
            })
    }

    var specificWord: Definition? = nil
    var isWordDefinitionView: Bool {
        specificWord != nil
    }
    @State var index: Int = 0
    @State var isPronounciationShown: Bool = false
    @State var isDefinitionShown: Bool = false

    var currentDefinition: Definition? {
        studyWords[safe: index]
    }

    var body: some View {
        let displayedDefinition = specificWord ?? currentDefinition
        Group {
            if let definition = displayedDefinition {
                wordView(definition: definition)
            } else {
                Text(LocalizedString.noSavedWords + "\n" + LocalizedString.tapWordToStudy)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Study") // TODO: Localize
        .onAppear {
            if !isWordDefinitionView {
                index = 0
                updateDefinition()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(FlowTaleColor.background)
        .scrollContentBackground(.hidden)
    }

    func goToNextDefinition() {
        index = (index + 1) % studyWords.count
        updateDefinition()
    }

    func updateDefinition() {
        isPronounciationShown = false
        isDefinitionShown = false
        if let definition = currentDefinition {
            store.dispatch(.updateStudiedWord(definition))
            store.dispatch(.updateStudyChapter(nil))
            store.dispatch(.prepareToPlayStudyWord(definition))
        }
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

    func wordView(definition: Definition) -> some View {
        let story = store.state.storyState.savedStories.first(where: { $0.id == definition.timestampData.storyId })
        let chapter = story?.chapters[safe: definition.timestampData.chapterIndex]
        let timestampData = chapter?.audio.timestamps.filter({ $0.sentenceIndex == definition.timestampData.sentenceIndex })
        var characterCount = 0
        for data in timestampData ?? [] {
            if data == definition.timestampData {
                break
            } else {
                characterCount += data.word.count
            }
        }
        let baseString = definition.sentence.translation

        return VStack(alignment: .leading) {
            Text(LocalizedString.word)
                .greyBackground()
            ZStack {
                Text(definition.timestampData.word)
                    .font(.system(size: 40, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Spacer()
                    Button {
                        store.dispatch(.playStudyWord(definition))
                    } label: {
                        SystemImageView(.speaker)
                    }
                    .disabled(store.state.studyState.currentChapter == nil)
                }
            }
            Text("Pronounciation") // TODO: Localize
                .greyBackground()
            Text(definition.detail.pronunciation)
                .font(.system(size: 30, weight: .light))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: isPronounciationShown ? 30 : 0)
                .animation(.easeInOut, value: isPronounciationShown)
            Text(LocalizedString.sentence)
                .greyBackground()
            if characterCount >= 0,
               characterCount + definition.timestampData.word.count <= baseString.count,
               let highlighted = boldSubstring(in: baseString, at: characterCount, length: definition.timestampData.word.count) {
                // In SwiftUI, just show it:
                Text(highlighted)
                    .font(.system(size: 30, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(definition.sentence.translation)
                    .font(.system(size: 30, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(LocalizedString.translation)
                .greyBackground()
            if isWordDefinitionView || isDefinitionShown {
                Text(definition.sentence.original)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(LocalizedString.tapRevealToShow)
            }
            Text(LocalizedString.definition)
                .greyBackground()
            if isWordDefinitionView || isDefinitionShown {
                ScrollView(.vertical) {
                    Text(definition.definition)
                        .frame(maxWidth: .infinity,
                               maxHeight: .infinity,
                               alignment: .topLeading)
                }
            } else {
                Text(LocalizedString.tapRevealToShow)
                Spacer()
            }

            HStack {
                if !isWordDefinitionView {
                    Button(LocalizedString.previous) {
                        if index - 1 < 0 {
                            index = studyWords.count - 1
                        } else {
                            index -= 1
                        }
                        isDefinitionShown = false
                        if let definition = currentDefinition {
                            store.dispatch(.updateStudyChapter(nil))
                            store.dispatch(.prepareToPlayStudyWord(definition))
                        }
                    }
                    .padding()
                    .background(FlowTaleColor.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    if isDefinitionShown {
                        Button(LocalizedString.next) {
                            goToNextDefinition()
                        }
                        .padding()
                        .background(FlowTaleColor.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    } else {
                        Button(LocalizedString.reveal) {
                            store.dispatch(.playStudyWord(definition))
                            isDefinitionShown = true
                        }
                        .padding()
                        .background(FlowTaleColor.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
