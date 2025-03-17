//
//  DefinitionsProgressView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import SwiftUI

struct StudyWord {
    let timestamp: WordTimeStampData
    let sentence: Sentence
}

struct DefinitionsProgressView: View {
    @EnvironmentObject var store: FlowTaleStore
    @State private var showingCreations = true
    @State private var navigateToStudyView = false
    @State private var showLanguageSelector = false
    
    // Helper function to build studyWords array - moved outside the body
    private func buildStudyWords() -> [StudyWord] {
        let sentences = store.state.definitionState.studySentences
        var result: [StudyWord] = []
        
        for sentence in sentences {
            for word in sentence.wordTimestamps {
                if word.hasBeenSeen && word.definition != nil {
                    result.append(StudyWord(timestamp: word, sentence: sentence))
                }
            }
        }
        
        return result
    }
    
    var body: some View {
        // Call the helper function instead of having loops in the body
        let studyWords = buildStudyWords()
        
        // Extract definitions from StudyWords for backward compatibility until fully migrated
        let definitions = studyWords.compactMap { $0.timestamp.definition }
        let studiedDefinitions = definitions.filter { !$0.studiedDates.isEmpty }
        
        let languageIcon = store.state.settingsState.language.flagEmoji
        let languageName = store.state.settingsState.language.displayName

        VStack(spacing: 0) {
            // Main content area
            if showingCreations {
                // Get all words with definitions for showing the saved words
                sheetContent(isCreations: true, 
                             definitions: definitions,
                             studyWords: studyWords)
            } else {
                // Filter to only show words that have been studied
                sheetContent(isCreations: false, 
                             definitions: studiedDefinitions,
                             studyWords: studyWords.filter {
                    !($0.timestamp.definition?.studiedDates.isEmpty ?? true)
                })
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
                        store.dispatch(.playSound(.togglePress))
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
                PrimaryButton(title: LocalizedString.studyNavTitle) {
                    navigateToStudyView = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(FlowTaleColor.background)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
            )
            .onAppear {
                store.dispatch(.loadDefinitions(store.state.settingsState.language))
            }
            .onChange(of: store.state.settingsState.language) {
                store.dispatch(.loadDefinitions(store.state.settingsState.language))
            }
        }
        .navigationDestination(isPresented: $navigateToStudyView) {
            // Create an empty sentence for the basic study view
            // The actual words will come from studyWords in the StudyView
            StudyView(studyWords: studyWords)
        }
        .navigationDestination(isPresented: $showLanguageSelector) {
            LanguageSettingsView()
        }
        .background(FlowTaleColor.background)
    }

    @ViewBuilder
    func sheetContent(isCreations: Bool, definitions: [Definition], studyWords: [StudyWord]) -> some View {
        NavigationView {
            VStack {
                // Pass chart data calculated directly from StudyWord objects
                DefinitionsChartView(
                    definitions: definitions, 
                    chartData: calculateChartStats(from: studyWords),
                    todayCreationCount: dailyCreationCount(from: studyWords),
                    todayStudiedCount: dailyStudiedCount(from: studyWords),
                    isCreations: isCreations
                )
                .frame(height: 300)
                
                List {
                    Section {
                        ForEach(studyWords, id: \.timestamp.id) { studyWord in
                            NavigationLink {
                                StudyView(studyWords: [studyWord])
                            } label: {
                                // Display the word from the timestamp
                                Text(studyWord.timestamp.definition?.detail.word ?? studyWord.timestamp.word)
                                    .fontWeight(.light)
                                    .foregroundStyle(FlowTaleColor.primary)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    // We already have both WordTimeStampData and Sentence
                                    store.dispatch(.deleteDefinition(studyWord.timestamp, studyWord.sentence))
                                    store.dispatch(.playSound(.actionButtonPress))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .tint(FlowTaleColor.error)
                                }
                            })
                        }
                    } header: {
                        Text(isCreations ?
                             // Count all StudyWords
                             LocalizedString.wordsSaved("\(studyWords.count)") :
                             // Count total study sessions across all words
                             LocalizedString.wordsStudied("\(studyWords.reduce(0) { $0 + ($1.timestamp.definition?.studiedDates.count ?? 0) })"))
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
            if !filteredDefinitions.contains(where: { $0.detail.word == def.detail.word }) {
                filteredDefinitions.append(def)
            }
        }
        return filteredDefinitions
    }
    
    // Helper function to get today's creation count directly from StudyWord objects
    func dailyCreationCount(from studyWords: [StudyWord]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return studyWords.filter { studyWord in
            guard let definition = studyWord.timestamp.definition else { return false }
            let creationDay = calendar.startOfDay(for: definition.creationDate)
            return calendar.isDate(creationDay, inSameDayAs: today)
        }.count
    }
    
    // Helper function to get today's studied count directly from StudyWord objects
    func dailyStudiedCount(from studyWords: [StudyWord]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var count = 0
        for studyWord in studyWords {
            guard let definition = studyWord.timestamp.definition else { continue }
            for studyDate in definition.studiedDates {
                let studyDay = calendar.startOfDay(for: studyDate)
                if calendar.isDate(studyDay, inSameDayAs: today) {
                    count += 1
                    break // Count each definition only once per day
                }
            }
        }
        
        return count
    }
    
    // Calculate daily creation and study data from StudyWord objects
    func calculateChartStats(from studyWords: [StudyWord]) -> [DailyCreationAndStudyStats] {
        guard !studyWords.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        
        // 1) Tally creation & study events by day
        var creationCountsByDay: [Date: Int] = [:]
        var studiedCountsByDay: [Date: Int] = [:]
        
        // Process each StudyWord's definition
        for studyWord in studyWords {
            guard let definition = studyWord.timestamp.definition else { continue }
            
            // Handle creation date
            let creationDateComponents = calendar.dateComponents([.year, .month, .day], from: definition.creationDate)
            let creationDay = calendar.date(from: DateComponents(
                year: creationDateComponents.year,
                month: creationDateComponents.month,
                day: creationDateComponents.day,
                hour: 0
            )) ?? calendar.startOfDay(for: definition.creationDate)
            
            // Shift the date to the NEXT day
            let shiftedCreationDay = calendar.date(from: DateComponents(
                year: creationDateComponents.year,
                month: creationDateComponents.month,
                day: creationDateComponents.day! + 1,
                hour: 0
            )) ?? calendar.date(byAdding: .day, value: 1, to: creationDay) ?? creationDay
            
            // Exclude today's data from historical cumulative
            if !calendar.isDate(creationDay, inSameDayAs: todayStart) {
                creationCountsByDay[shiftedCreationDay, default: 0] += 1
            }
            
            // Process study dates
            for studyDate in definition.studiedDates {
                let studyDateComponents = calendar.dateComponents([.year, .month, .day], from: studyDate)
                let studyDay = calendar.date(from: DateComponents(
                    year: studyDateComponents.year,
                    month: studyDateComponents.month,
                    day: studyDateComponents.day,
                    hour: 0
                )) ?? calendar.startOfDay(for: studyDate)
                
                // Shift the date to the NEXT day
                let shiftedStudyDay = calendar.date(from: DateComponents(
                    year: studyDateComponents.year,
                    month: studyDateComponents.month,
                    day: studyDateComponents.day! + 1,  
                    hour: 0
                )) ?? calendar.date(byAdding: .day, value: 1, to: studyDay) ?? studyDay
                
                // Exclude today's data from historical cumulative
                if !calendar.isDate(studyDay, inSameDayAs: todayStart) {
                    studiedCountsByDay[shiftedStudyDay, default: 0] += 1
                }
            }
        }
        
        // 2) Combine all days (creation + study) - excluding today
        let allDays = Set(creationCountsByDay.keys)
            .union(studiedCountsByDay.keys)
        let sortedDays = allDays.sorted()
        
        // 3) Build cumulative totals for past days
        var results: [DailyCreationAndStudyStats] = []
        var runningCreations = 0
        var runningStudied = 0
        for day in sortedDays {
            runningCreations += creationCountsByDay[day] ?? 0
            runningStudied += studiedCountsByDay[day] ?? 0
            results.append(
                DailyCreationAndStudyStats(
                    date: day,
                    cumulativeCreations: runningCreations,
                    cumulativeStudied: runningStudied
                )
            )
        }
        
        // 4) Insert a day-before entry so the chart can start at 0
        if let earliestDay = sortedDays.first {
            let components = calendar.dateComponents([.year, .month, .day], from: earliestDay)
            if let dayBeforeComponents = calendar.date(from: components),
               let dayBeforeEarliest = calendar.date(byAdding: .day, value: -1, to: dayBeforeComponents) {
                // Create a date at the start of the day before
                let dayBeforeStart = calendar.date(from: DateComponents(
                    year: calendar.component(.year, from: dayBeforeEarliest),
                    month: calendar.component(.month, from: dayBeforeEarliest),
                    day: calendar.component(.day, from: dayBeforeEarliest),
                    hour: 0
                )) ?? dayBeforeEarliest
                
                let zeroStats = DailyCreationAndStudyStats(
                    date: dayBeforeStart,
                    cumulativeCreations: 0,
                    cumulativeStudied: 0
                )
                results.insert(zeroStats, at: 0)
            }
        }
        
        return results
    }
    
    // Find a StudyWord that contains this definition
    func findStudyWord(for definition: Definition, in studyWords: [StudyWord]) -> StudyWord? {
        return studyWords.first { studyWord in
            studyWord.timestamp.definition?.id == definition.id || 
            studyWord.timestamp.definition?.detail.word == definition.detail.word
        }
    }
    
    // This method will be removed when the migration to StudyWord is complete
    // Helper to find the WordTimeStampData that contains this definition
    func findWordTimeStampData(for definition: Definition) -> (word: WordTimeStampData?, sentence: Sentence?) {
        for story in store.state.storyState.savedStories where story.language == definition.language {
            for chapter in story.chapters {
                for sentence in chapter.sentences {
                    if let word = sentence.wordTimestamps.first(where: { 
                        $0.definition?.id == definition.id || 
                        $0.definition?.detail.word == definition.detail.word 
                    }) {
                        return (word, sentence)
                    }
                }
            }
        }
        return (nil, nil)
    }
}
