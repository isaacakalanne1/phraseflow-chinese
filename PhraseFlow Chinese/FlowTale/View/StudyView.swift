//
//  StudyView.swift
//  FlowTale
//
//  Created by iakalann on 26/12/2024.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var store: FlowTaleStore

    var studyWords: [Definition]

    var isPronounciationShown: Bool {
        store.state.studyState.displayStatus != .wordShown
    }

    var isDefinitionShown: Bool {
        store.state.studyState.displayStatus == .allShown
    }

    @State var index: Int = 0
    var currentDefinition: Definition? {
        studyWords[safe: index]
    }

    var isWordDefinitionView: Bool {
        studyWords.count == 1
    }

    var body: some View {
        VStack {
            if let definition = currentDefinition {
                ScrollView {
                    wordView(definition: definition)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
                .onTapGesture {
                    withAnimation {
                        let nextStatus = store.state.studyState.displayStatus.nextStatus
                        store.dispatch(.studyAction(.updateDisplayStatus(nextStatus)))
                    }
                }
                buttons(definition: definition)
                    .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .navigationTitle(LocalizedString.studyNavTitle)
        .onAppear {
            index = 0
            updateDefinition()
            store.dispatch(.snackbarAction(.checkDeviceVolumeZero))
        }
        .padding()
        .background(.ftBackground)
    }

    func buttons(definition: Definition) -> some View {
        HStack {
            if !isWordDefinitionView {
                PrimaryButton(title: LocalizedString.previous, shouldPlaySound: false) {
                    goToPreviousDefinition()
                }
                PrimaryButton(title: isDefinitionShown ? LocalizedString.next : LocalizedString.reveal, shouldPlaySound: false) {
                    nextTapped(definition: definition)
                }
            }
        }
    }

    private func nextTapped(definition: Definition) {
        if isDefinitionShown {
            goToNextDefinition()
        } else {
            store.dispatch(.studyAction(.playStudyWord(definition)))
            withAnimation {
                store.dispatch(.studyAction(.updateDisplayStatus(.allShown)))
            }
        }
    }

    func goToPreviousDefinition() {
        if index - 1 < 0 {
            index = studyWords.count - 1
        } else {
            index -= 1
        }
        store.dispatch(.audioAction(.playSound(.previousStudyWord)))
        updateDefinition()
    }

    func goToNextDefinition() {
        if let definition = currentDefinition {
            store.dispatch(.definitionAction(.updateStudiedWord(definition)))
        }
        index = (index + 1) % studyWords.count
        store.dispatch(.audioAction(.playSound(.nextStudyWord)))
        updateDefinition()
    }

    func updateDefinition() {
        store.dispatch(.studyAction(.updateDisplayStatus(.wordShown)))
        if let definition = currentDefinition {
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
        let endIndex = baseString.index(startIndex, offsetBy: length)
        let substring = baseString[startIndex ..< endIndex]

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
                    .font(.flowTaleBodyXLarge())
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
                    .font(.flowTaleBodySmall())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scaleEffect(x: 1, y: isWordDefinitionView || isPronounciationShown ? 1 : 0, anchor: .top)
            .opacity(isWordDefinitionView || isPronounciationShown ? 1 : 0)
            Text(LocalizedString.definition)
                .greyBackground()
            Group {
                Text(LocalizedString.studyDefinitionPrefix + definition.detail.definition)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.flowTaleBodySmall())
                Divider()
                Text(LocalizedString.studyContextPrefix + definition.detail.definitionInContextOfSentence)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
                    .font(.flowTaleBodySmall())
            }
            .opacity(isWordDefinitionView || isDefinitionShown ? 1 : 0)
            .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
            Text(LocalizedString.sentence)
                .greyBackground()
            HStack {
                if characterCount >= 0,
                   characterCount + definition.timestampData.word.count <= baseString.count,
                   let highlighted = boldSubstring(in: baseString, at: characterCount, length: definition.timestampData.word.count)
                {
                    Text(highlighted)
                        .font(.flowTaleBodyLarge())
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(definition.sentence.translation)
                        .font(.flowTaleBodyLarge())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button {
                    if store.state.studyState.isAudioPlaying {
                        store.dispatch(.studyAction(.pauseStudyAudio))
                    } else {
                        store.dispatch(.studyAction(.playStudySentence))
                    }
                } label: {
                    SystemImageView(.speaker)
                }
            }
            Text(LocalizedString.translation)
                .greyBackground()
            Text(definition.sentence.original)
                .font(.flowTaleBodySmall())
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isWordDefinitionView || isDefinitionShown ? 1 : 0)
                .scaleEffect(x: 1, y: isWordDefinitionView || isDefinitionShown ? 1 : 0, anchor: .top)
        }
    }
}
