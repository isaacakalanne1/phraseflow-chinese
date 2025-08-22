//
//  DefinitionsProgressView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import Audio
import FTColor
import FTFont
import FTStyleKit
import Localization
import Settings
import SwiftUI

struct DefinitionsProgressView: View {
    @EnvironmentObject var store: StudyStore
    @State private var showingCreations = true
    @State private var navigateToStudyView = false
    
    var filterLanguage: Language {
        store.state.filterLanguage
    }

    var body: some View {
        let definitions = store.state.studyDefinitions(language: filterLanguage)
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
                // Segmented control
                Picker("", selection: $showingCreations) {
                    Text(LocalizedString.saved).tag(true)
                    Text(LocalizedString.studied).tag(false)
                }
                .pickerStyle(.segmented)
                .onChange(of: showingCreations) { _, _ in
                    store.dispatch(.playSound(.togglePress))
                }

                // Practice button
                if filteredDefinitions.count > 0 {
                    PrimaryButton(title: LocalizedString.studyNavTitle) {
                        navigateToStudyView = true
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(FTColor.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
            )
        }
        .navigationDestination(isPresented: $navigateToStudyView) {
            StudyView(studyWords: store.state.studyDefinitions(language: filterLanguage))
                .environmentObject(store)
        }
        .background(FTColor.background)
    }

    @ViewBuilder
    func sheetContent(isCreations: Bool, definitions: [Definition]) -> some View {
        NavigationView {
            VStack {
                DefinitionsChartView(definitions: definitions, isCreations: isCreations)
                    .frame(height: 300)

                definitionsList(definitions: definitions, isCreations: isCreations)
            }
            .background(FTColor.background)
        }
    }
    
    @ViewBuilder
    private func definitionsList(definitions: [Definition], isCreations: Bool) -> some View {
        List {
            Section {
                ForEach(definitions, id: \.self) { definition in
                    definitionRow(definition: definition)
                }
            } header: {
                sectionHeader(definitions: definitions, isCreations: isCreations)
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .background(FTColor.background)
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private func definitionRow(definition: Definition) -> some View {
        NavigationLink {
            StudyView(studyWords: [definition])
                .environmentObject(store)
        } label: {
            Text(definition.timestampData.word)
                .fontWeight(.light)
                .foregroundStyle(FTColor.primary)
        }
        .foregroundStyle(FTColor.secondary)
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                store.dispatch(.deleteDefinition(definition))
                store.dispatch(.playSound(.actionButtonPress))
            } label: {
                Label("Delete", systemImage: "trash")
                    .tint(FTColor.error)
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(definitions: [Definition], isCreations: Bool) -> some View {
        let headerText: String = {
            if isCreations {
                return LocalizedString.wordsSaved("\(definitions.count)")
            } else {
                let totalStudiedCount = definitions.reduce(0) { $0 + $1.studiedDates.count }
                return LocalizedString.wordsStudied("\(totalStudiedCount)")
            }
        }()
        Text(headerText)
            .foregroundStyle(FTColor.secondary)
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
