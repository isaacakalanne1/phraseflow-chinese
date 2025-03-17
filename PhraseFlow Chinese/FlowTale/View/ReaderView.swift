//
//  ReaderView.swift
//  FlowTale
//
//  Created by iakalann on 25/10/2024.
//

import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var store: FlowTaleStore
    let chapter: Chapter
    @State var chapterViewId = UUID()

    var body: some View {
        VStack(spacing: 10) {
            AIStatementView()
            if store.state.settingsState.isShowingDefinition {
                DefinitionView()
                    .frame(height: 150)
            }
            if store.state.settingsState.isShowingEnglish {
                EnglishSentenceView()
                    .frame(height: 120)
            }
            ChapterHeaderView(chapter: chapter)
            ChapterView(chapter: chapter)
                .onAppear {
                    // Check if device is in silent mode when reader view appears
                    store.dispatch(.checkDeviceVolumeZero)
                }
                .id(store.state.viewState.chapterViewId)
        }
        .overlay(content: {
            VStack(alignment: .trailing) {
                Spacer()
                    .frame(maxWidth: .infinity)
                audioButton(chapter: chapter)
                    .background(FlowTaleColor.background)
                    .clipShape(Circle())
                    .padding(.trailing)
                Button {
                    store.dispatch(.updateSpeechSpeed(store.state.settingsState.speechSpeed.nextSpeed))
                } label: {
                    Text(store.state.settingsState.speechSpeed.text)
                        .foregroundStyle(FlowTaleColor.primary)
                }
                .buttonStyle(.bordered)
                .frame(width: 80)
            }
        })
        .padding(10)
        .background {
            if let uiImage = UIImage(named: "Background") {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        FlowTaleColor.background.opacity(0.9)
                    }
            }
        }
    }

    // MARK: - Audio Button
    @ViewBuilder
    func audioButton(chapter: Chapter) -> some View {
        let buttonSize: CGFloat = 50
        if store.state.storyState.readerDisplayType == .normal {
            if store.state.storyState.isPlayingAudio == true {
                Button {
                    store.dispatch(.pauseAudio)
                } label: {
                    SystemImageView(.pause, size: buttonSize)
                }
            } else {
                Button {
                    // Flatten timestamps from all sentences
                    let timestamps = chapter.sentences.flatMap { $0.wordTimestamps }
                    let currentSpokenWord = store.state.storyState.currentSpokenWord ?? timestamps.first
                    store.dispatch(.playAudio(time: currentSpokenWord?.time))
                    store.dispatch(.updateAutoScrollEnabled(isEnabled: true))
                } label: {
                    SystemImageView(.play, size: buttonSize)
                }
            }
        }
    }
}
