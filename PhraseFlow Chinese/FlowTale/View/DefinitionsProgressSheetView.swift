//
//  DefinitionsProgressSheetView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import SwiftUI

struct DefinitionsProgressSheetView: View {
    @EnvironmentObject var store: FlowTaleStore
    @State private var showingCreations = true
    @State private var navigateToStudyView = false
    @State private var showLanguageSelector = false

    var body: some View {
        let filterLanguage = store.state.settingsState.language
        let definitions = store.state.definitionState.studyDefinitions(language: filterLanguage)
        let filteredDefinitions = removeDuplicates(from: definitions)
        let studiedDefinitions = filteredDefinitions.filter { !$0.studiedDates.isEmpty }

        let languageIcon = filterLanguage.flagEmoji
        let languageName = filterLanguage.displayName

        VStack(spacing: 0) {
            // Main content area
            if showingCreations {
                sheetContent(isCreations: true, definitions: filteredDefinitions)
            } else {
                sheetContent(isCreations: false, definitions: studiedDefinitions)
            }

            // Bottom control area
            VStack(spacing: 16) {
                // Top row: Tabs and Language selector
                HStack {
                    // Segmented control
                    Picker("", selection: $showingCreations) {
                        Text(LocalizedString.saved).tag(true)
                        Text(LocalizedString.studied).tag(false)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: showingCreations) { _, _ in
                        store.dispatch(.audioAction(.playSound(.togglePress)))
                    }

                    Spacer()

                    // Language selector
                    Button {
                        showLanguageSelector = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(languageIcon)
                                .font(.system(size: 16))
                            Text(languageName)
                                .font(.footnote)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(FlowTaleColor.primary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(FlowTaleColor.background)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                                )
                        )
                    }
                }

                // Practice button
                if filteredDefinitions.count > 1 {
                    PrimaryButton(title: LocalizedString.studyNavTitle) {
                        navigateToStudyView = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(FlowTaleColor.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
            )
        }
        .navigationDestination(isPresented: $navigateToStudyView) {
            let language = store.state.storyState.currentStory?.language
            StudyView(studyWords: store.state.definitionState.studyDefinitions(language: language))
        }
        .navigationDestination(isPresented: $showLanguageSelector) {
            LanguageSettingsView()
        }
        .background(FlowTaleColor.background)
    }

    @ViewBuilder
    func sheetContent(isCreations: Bool, definitions: [Definition]) -> some View {
        NavigationView {
            VStack {
                DefinitionsChartView(definitions: definitions, isCreations: isCreations)
                    .frame(height: 300)

                List {
                    Section {
                        ForEach(definitions, id: \.self) { definition in
                            NavigationLink {
                                StudyView(studyWords: [definition])
                            } label: {
                                Text(definition.timestampData.word)
                                    .fontWeight(.light)
                                    .foregroundStyle(FlowTaleColor.primary)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    store.dispatch(.deleteDefinition(definition))
                                    store.dispatch(.audioAction(.playSound(.actionButtonPress)))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .tint(FlowTaleColor.error)
                                }
                            })
                        }
                    } header: {
                        Text(isCreations ?
                            LocalizedString.wordsSaved("\(definitions.count)") :
                            LocalizedString.wordsStudied("\(definitions.reduce(0) { $0 + $1.studiedDates.count })"))
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(ContentTab.progress.title)
                .navigationBarTitleDisplayMode(.inline)
                .background(FlowTaleColor.background)
                .scrollContentBackground(.hidden)
            }
            .background(FlowTaleColor.background)
        }
    }

    func removeDuplicates(from definitions: [Definition]) -> [Definition] {
        var filteredDefinitions: [Definition] = []
        for def in definitions {
            if !filteredDefinitions.contains(where: { $0.timestampData.word == def.timestampData.word }) {
                filteredDefinitions.append(def)
            }
        }
        return filteredDefinitions
    }
}
