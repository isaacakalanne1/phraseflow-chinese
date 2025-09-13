//
//  StudyView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import Localization
import SwiftUI
import FTColor
import FTFont
import FTStyleKit
import AppleIcon
import ReduxKit

public struct StudyView: View {
    @EnvironmentObject var store: StudyStore

    public let studyWords: [Definition]
    
    public init(studyWords: [Definition]) {
        self.studyWords = studyWords
    }

    var isPronounciationShown: Bool {
        store.state.displayStatus != .wordShown || shouldShowAllDetails
    }

    var isDefinitionShown: Bool {
        store.state.displayStatus == .allShown || shouldShowAllDetails
    }

    @State var index: Int = 0
    var currentDefinition: Definition? {
        studyWords.indices.contains(index) ? studyWords[index] : nil
    }

    var shouldShowAllDetails: Bool {
        studyWords.count == 1
    }

    public var body: some View {
        VStack {
            if let definition = currentDefinition {
                ScrollView {
                    let characterCount = definition.sentence.original.count
                    let baseString = definition.sentence.translation

                    VStack(alignment: .leading) {
                        ZStack {
                            Text(definition.timestampData.word)
                                .font(FTFont.flowTaleBodyXLarge())
                                .frame(maxWidth: .infinity, alignment: .center)
                            HStack {
                                Spacer()
                                Button {
                                    store.dispatch(.playStudyWord)
                                } label: {
                                    SystemImageView(.speaker)
                                }
                            }
                        }

                        StudySection(
                            title: LocalizedString.studyPronunciationLabel,
                            isShown: isPronounciationShown,
                            content:
                            VStack {
                                Text(LocalizedString.studyPronunciationPrefix + definition.detail.pronunciation)
                                    .font(FTFont.flowTaleBodySmall())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )

                        StudySection(
                            title: LocalizedString.definition,
                            isShown: isDefinitionShown,
                            content:
                                Group {
                                    Text(LocalizedString.studyDefinitionPrefix + definition.detail.definition)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(FTFont.flowTaleBodySmall())
                                    Divider()
                                    Text(LocalizedString.studyContextPrefix + definition.detail.definitionInContextOfSentence)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .scaleEffect(x: 1, y: isDefinitionShown ? 1 : 0, anchor: .top)
                                        .font(FTFont.flowTaleBodySmall())
                                }
                        )

                        StudySection(
                            title: LocalizedString.sentence,
                            isShown: true,
                            content:
                                HStack {
                                    let wordToHighlight = definition.timestampData.word
                                    let highlighted = highlightWord(wordToHighlight, in: baseString) ?? AttributedString(definition.sentence.translation)

                                    Text(highlighted)
                                        .font(FTFont.flowTaleBodyLarge())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Button {
                                        let studyAction: StudyAction = store.state.isAudioPlaying ? .pauseStudyAudio : .playStudySentence
                                        store.dispatch(studyAction)
                                    } label: {
                                        SystemImageView(.speaker)
                                    }
                                }
                        )

                        StudySection(
                            title: LocalizedString.translation,
                            isShown: isDefinitionShown,
                            content:
                                Text(definition.sentence.original)
                                    .font(FTFont.flowTaleBodySmall())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
                .onTapGesture {
                    withAnimation {
                        let nextStatus = store.state.displayStatus.nextStatus
                        store.dispatch(.updateDisplayStatus(nextStatus))
                    }
                }
                HStack {
                    if !shouldShowAllDetails {
                        PrimaryButton(
                            title: LocalizedString.previous
                        ) {
                            goToPreviousDefinition()
                        }

                        PrimaryButton(
                            title: isDefinitionShown ? LocalizedString.next : LocalizedString.reveal
                        ) {
                            nextTapped()
                        }
                    }
                }
            }
        }
        .navigationTitle(LocalizedString.studyNavTitle)
        .onAppear {
            index = 0
            updateDefinition()
            // Volume warning handled at app level
        }
        .padding()
        .background(FTColor.background)
        .foregroundStyle(FTColor.primary)
    }

    private func nextTapped() {
        if isDefinitionShown {
            goToNextDefinition()
        } else {
            store.dispatch(.playStudyWord)
            withAnimation {
                store.dispatch(.updateDisplayStatus(.allShown))
            }
        }
    }

    func goToPreviousDefinition() {
        // Navigation sound handled at app level

        if index - 1 < 0 {
            index = studyWords.count - 1
        } else {
            index -= 1
        }
        updateDefinition()
    }

    func goToNextDefinition() {
        // Navigation sound handled at app level
        if var definition = currentDefinition {
            definition.studiedDates.append(.now)
            store.dispatch(.saveDefinitions([definition]))
        }

        index = (index + 1) % studyWords.count
        updateDefinition()
    }

    func updateDefinition() {
        store.dispatch(.updateDisplayStatus(.wordShown))
        if let definition = currentDefinition {
            store.dispatch(.prepareToPlayStudyWord(definition))
            store.dispatch(.prepareToPlayStudySentence(definition))
            store.dispatch(.pauseStudyAudio)
        }
    }

    func highlightWord(_ word: String, in sentence: String) -> AttributedString? {
        var attributed = AttributedString(sentence)
        
        let lowercasedWord = word.lowercased()
        let lowercasedSentence = sentence.lowercased()
        
        if let range = lowercasedSentence.range(of: lowercasedWord) {
            let startIndex = sentence.distance(from: sentence.startIndex, to: range.lowerBound)
            let endIndex = sentence.distance(from: sentence.startIndex, to: range.upperBound)
            
            let nsRange = NSRange(location: startIndex, length: endIndex - startIndex)
            
            if let attributedRange = Range(nsRange, in: attributed) {
                attributed[attributedRange].font = .system(size: 30, weight: .bold)
            }
            
            return attributed
        }
        
        return nil
    }

}
