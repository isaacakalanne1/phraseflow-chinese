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
        let studiedDefinitions = filteredDefinitions.filter({ !$0.studiedDates.isEmpty })
        
        let languageIcon = filterLanguage.flagEmoji
        let languageName = filterLanguage.displayName

        VStack {
            if showingCreations {
                sheetContent(isCreations: true, definitions: filteredDefinitions)
            } else {
                sheetContent(isCreations: false, definitions: studiedDefinitions)
            }
            
            Spacer()
            
            // Language Selector Button
            Button {
                showLanguageSelector = true
            } label: {
                HStack {
                    Text(languageIcon)
                        .font(.title2)
                    Text(languageName)
                        .font(.subheadline)
                        .foregroundColor(FlowTaleColor.primary)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(FlowTaleColor.primary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(FlowTaleColor.background)
                        .overlay(
                            Capsule()
                                .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            HStack {
                // Custom tab selector
                ZStack {
                    Capsule()
                        .fill(FlowTaleColor.background)
                        .overlay(
                            Capsule()
                                .strokeBorder(FlowTaleColor.secondary, lineWidth: 1)
                        )
                        .frame(height: 60)
                    
                    HStack(spacing: 4) {
                        // Saved tab
                        Button(action: {
                            if !showingCreations {
                                withAnimation {
                                    showingCreations = true
                                    store.dispatch(.playSound(.actionButtonPress))
                                }
                            }
                        }) {
                            Text(LocalizedString.saved)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(showingCreations ? FlowTaleColor.primary : Color.clear)
                                )
                                .foregroundStyle(showingCreations ? FlowTaleColor.background : FlowTaleColor.primary)
                        }
                        
                        // Studied tab
                        Button(action: {
                            if showingCreations {
                                withAnimation {
                                    showingCreations = false
                                    store.dispatch(.playSound(.actionButtonPress))
                                }
                            }
                        }) {
                            Text(LocalizedString.studied)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(!showingCreations ? FlowTaleColor.primary : Color.clear)
                                )
                                .foregroundStyle(!showingCreations ? FlowTaleColor.background : FlowTaleColor.primary)
                        }
                    }
                }
                .padding(.leading)
                
                Spacer()
                
                // Practice button
                PrimaryButton(title: LocalizedString.studyNavTitle) {
                    navigateToStudyView = true
                }
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .navigationDestination(isPresented: $navigateToStudyView) {
            StudyView()
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
                                StudyView(specificWord: definition)
                            } label: {
                                Text(definition.timestampData.word)
                                    .fontWeight(.light)
                                    .foregroundStyle(FlowTaleColor.primary)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    store.dispatch(.deleteDefinition(definition))
                                    store.dispatch(.playSound(.actionButtonPress))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .tint(FlowTaleColor.error)
                                }
                            })
                        }
                    } header: {
                        Text(isCreations ?
                             LocalizedString.wordsSaved("\(definitions.count)") :
                                LocalizedString.wordsStudied("\(definitions.reduce(0, { $0 + $1.studiedDates.count }))"))
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
