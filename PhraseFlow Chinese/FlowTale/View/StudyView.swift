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
        let language = store.state.storyState.currentStory?.language
        return store.state.definitionState.studyDefinitions(language: language)
    }

    var displayedDefinition: Definition? {
        specificWord ?? currentDefinition
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
        return Group {
            if let definition = displayedDefinition {
                VStack {
                    ScrollView {
                        wordView(definition: definition)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollIndicators(.hidden)
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
                    buttons(definition: definition)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
        }
        .navigationTitle(LocalizedString.studyNavTitle)
        .onAppear {
            index = 0
            updateDefinition()
            store.dispatch(.checkDeviceVolumeZero)
        }
        .padding()
        .background(FlowTaleColor.background)
    }

    func buttons(definition: Definition) -> some View {
        HStack {
            if !isWordDefinitionView {
                Button {
                    goToPreviousDefinition()
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
                        goToNextDefinition()
                    } else {
                        store.dispatch(.studyAction(.playStudyWord(definition)))
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
        }
    }

    func goToPreviousDefinition() {
        if index - 1 < 0 {
            index = studyWords.count - 1
        } else {
            index -= 1
        }
        store.dispatch(.playSound(.previousStudyWord))
        updateDefinition()
    }

    func goToNextDefinition() {
        if let definition = displayedDefinition {
            store.dispatch(.updateStudiedWord(definition))
        }
        index = (index + 1) % studyWords.count
        store.dispatch(.playSound(.nextStudyWord))
        updateDefinition()
    }

    func updateDefinition() {
        isPronounciationShown = false
        isDefinitionShown = false
        if let definition = specificWord ?? currentDefinition {
            store.dispatch(.studyAction(.prepareToPlayStudySentence(definition)))
            store.dispatch(.studyAction(.pauseStudyAudio))
        }
    }

    func boldSubstring(in baseString: String,
                       at characterOffset: Int,
                       length: Int) -> AttributedString?
    {
        guard characterOffset >= 0,
              length > 0,
              characterOffset + length <= baseString.count
        else {
            return nil
        }

        let startIndex = baseString.index(baseString.startIndex, offsetBy: characterOffset)
        let endIndex   = baseString.index(startIndex, offsetBy: length)
        let substring  = baseString[startIndex..<endIndex]

        var attributed = AttributedString(baseString)

        if let rangeInAttributed = attributed.range(of: String(substring)) {
            attributed[rangeInAttributed].font = .system(size: 30, weight: .bold)
        }

        return attributed
    }

    func wordView(definition: Definition) -> some View {
        let characterCount = definition.sentence.original.count
        let baseString = definition.sentence.translation

        return VStack(alignment: .leading) {
            ZStack {
                Text(definition.timestampData.word)
                    .font(.system(size: 60, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Spacer()
                    Button {
                        store.dispatch(.studyAction(.playStudyWord(definition)))
                    } label: {
                        SystemImageView(.speaker)
                    }
                }
            }
            Text(LocalizedString.studyPronunciationLabel)
                .greyBackground()
            VStack {
                Text(LocalizedString.studyPronunciationPrefix + definition.detail.pronunciation)
                    .font(.system(size: 20, weight: .light))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scaleEffect(x: 1, y: isWordDefinitionView || isPronounciationShown ? 1 : 0, anchor: .top)
            .opacity(isWordDefinitionView || isPronounciationShown ? 1 : 0)
            Text(LocalizedString.definition)
                .greyBackground()
            Group {
                Text(LocalizedString.studyDefinitionPrefix + definition.detail.definition)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 20, weight: .light))
                Divider()
                Text(LocalizedString.studyContextPrefix + definition.detail.definitionInContextOfSentence)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
                    .font(.system(size: 20, weight: .light))
            }
            .opacity(isWordDefinitionView || isDefinitionShown ? 1 : 0)
            .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
            Text(LocalizedString.sentence)
                .greyBackground()
            HStack {
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
                Button {
                    if store.state.studyState.isAudioPlaying {
                        store.dispatch(.studyAction(.pauseStudyAudio))
                    } else {
                        store.dispatch(.studyAction(.playStudySentence))
                    }
                } label: {
                    SystemImageView(store.state.studyState.isAudioPlaying ? .stop : .play)
                }
            }
            Text(LocalizedString.translation)
                .greyBackground()
            Text(definition.sentence.original)
                .font(.system(size: 20, weight: .light))
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isWordDefinitionView || isDefinitionShown ? 1 : 0)
                .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
        }
    }
}
