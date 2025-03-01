//
//  DefinitionState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct DefinitionState {
    var tappedWord: WordTimeStampData?
    var currentDefinition: Definition?
    var definitions: [Definition]

    func studyDefinitions(language: Language?) -> [Definition] {
        definitions
            .filter {
                $0.language == language &&
                !$0.timestampData.word.trimmingCharacters(in: CharacterSet.punctuationCharacters).isEmpty &&
                $0.hasBeenSeen
            }
            .sorted(by: { $0.creationDate > $1.creationDate })
    }

    init(tappedWord: WordTimeStampData? = nil,
         currentDefinition: Definition? = nil,
         definitions: [Definition] = []) {
        self.tappedWord = tappedWord
        self.currentDefinition = currentDefinition
        self.definitions = definitions
    }

    func definition(timestampData: WordTimeStampData, in sentence: Sentence) -> Definition? {
        definitions.first(where: { $0.timestampData == timestampData && $0.sentence == sentence })
    }

}

struct DailyCreationAndStudyStats: Identifiable {
    let id = UUID()
    let date: Date
    let cumulativeCreations: Int
    let cumulativeStudied: Int
}

extension DefinitionState {

    func dailyCreationAndStudyCumulative(from definitions: [Definition]) -> [DailyCreationAndStudyStats] {
        guard !definitions.isEmpty else { return [] }

        let calendar = Calendar.current

        // 1) Tally creation & study events by day
        var creationCountsByDay: [Date: Int] = [:]
        var studiedCountsByDay: [Date: Int] = [:]

        for def in definitions {
            // Creation - use start of day for consistent positioning
            let creationDateComponents = calendar.dateComponents([.year, .month, .day], from: def.creationDate)
            // Create a date at the start of the day
            let creationDay = calendar.date(from: DateComponents(
                year: creationDateComponents.year,
                month: creationDateComponents.month,
                day: creationDateComponents.day,
                hour: 0
            )) ?? calendar.startOfDay(for: def.creationDate)
            
            creationCountsByDay[creationDay, default: 0] += 1

            // Studied - also use start of day for consistent positioning
            for studyDate in def.studiedDates {
                let studyDateComponents = calendar.dateComponents([.year, .month, .day], from: studyDate)
                // Create a date at the start of the day
                let studyDay = calendar.date(from: DateComponents(
                    year: studyDateComponents.year,
                    month: studyDateComponents.month,
                    day: studyDateComponents.day,
                    hour: 0
                )) ?? calendar.startOfDay(for: studyDate)
                
                studiedCountsByDay[studyDay, default: 0] += 1
            }
        }

        // 2) Combine all days (creation + study)
        let allDays = Set(creationCountsByDay.keys)
            .union(studiedCountsByDay.keys)
        let sortedDays = allDays.sorted()

        // 3) Build cumulative totals
        var results: [DailyCreationAndStudyStats] = []
        var runningCreations = 0
        var runningStudied   = 0
        for day in sortedDays {
            runningCreations += creationCountsByDay[day] ?? 0
            runningStudied   += studiedCountsByDay[day]   ?? 0
            results.append(
                DailyCreationAndStudyStats(
                    date: day,
                    cumulativeCreations: runningCreations,
                    cumulativeStudied: runningStudied
                )
            )
        }

        // 4) Insert a day-before entry so the chart can start at 0
        // Use a time at noon the day before the first date
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
}
