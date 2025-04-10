//
//  DefinitionState.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct DefinitionState {
    var currentDefinition: Definition?
    var definitions: [Definition]

    var numberOfInitialSentencesToDefine: Int {
        3
    }

    func studyDefinitions(language: Language?) -> [Definition] {
        definitions
            .filter {
                $0.language == language &&
                !$0.timestampData.word.trimmingCharacters(in: CharacterSet.punctuationCharacters).isEmpty &&
                $0.hasBeenSeen
            }
            .sorted(by: { $0.creationDate > $1.creationDate })
    }

    init(currentDefinition: Definition? = nil,
         definitions: [Definition] = []) {
        self.currentDefinition = currentDefinition
        self.definitions = definitions
    }

    func definition(timestampData: WordTimeStampData?) -> Definition? {
        definitions.first(where: { $0.timestampData == timestampData })
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
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        
        // 1) Tally creation & study events by day
        var creationCountsByDay: [Date: Int] = [:]
        var studiedCountsByDay: [Date: Int] = [:]
        
        // We won't track today's data here - those will be handled
        // directly in the chart view with the "Now" point

        for def in definitions {
            let creationDateComponents = calendar.dateComponents([.year, .month, .day], from: def.creationDate)
            let creationDay = calendar.date(from: DateComponents(
                year: creationDateComponents.year,
                month: creationDateComponents.month,
                day: creationDateComponents.day,
                hour: 0
            )) ?? calendar.startOfDay(for: def.creationDate)
            
            // Shift the date to the NEXT day (1st → 2nd, 2nd → 3rd, etc.)
            // Use midnight of the next day for consistency
            let shiftedCreationDay = calendar.date(from: DateComponents(
                year: creationDateComponents.year,
                month: creationDateComponents.month,
                day: creationDateComponents.day! + 1,  // Add one day directly to the component
                hour: 0
            )) ?? calendar.date(byAdding: .day, value: 1, to: creationDay) ?? creationDay
            
            // Always shift definitions to the NEXT day, but exclude today's data from historical cumulative
            // This ensures definitions from 28th appear on the date point for the 29th
            if !calendar.isDate(creationDay, inSameDayAs: todayStart) {
                creationCountsByDay[shiftedCreationDay, default: 0] += 1
            }

            // Process study dates
            for studyDate in def.studiedDates {
                let studyDateComponents = calendar.dateComponents([.year, .month, .day], from: studyDate)
                let studyDay = calendar.date(from: DateComponents(
                    year: studyDateComponents.year,
                    month: studyDateComponents.month,
                    day: studyDateComponents.day,
                    hour: 0
                )) ?? calendar.startOfDay(for: studyDate)
                
                // Shift the date to the NEXT day (1st → 2nd, 2nd → 3rd, etc.)
                // Use midnight of the next day for consistency
                let shiftedStudyDay = calendar.date(from: DateComponents(
                    year: studyDateComponents.year,
                    month: studyDateComponents.month,
                    day: studyDateComponents.day! + 1,  // Add one day directly to the component
                    hour: 0
                )) ?? calendar.date(byAdding: .day, value: 1, to: studyDay) ?? studyDay
                
                // Always shift to the NEXT day, but exclude today's data from historical cumulative
                // This ensures studied words from 28th appear on the date point for the 29th
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
    
    /// Returns the count of definitions created today
    func dailyCreationCount(from definitions: [Definition]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return definitions.filter { definition in
            let creationDay = calendar.startOfDay(for: definition.creationDate)
            return calendar.isDate(creationDay, inSameDayAs: today)
        }.count
    }
    
    /// Returns the count of definitions studied today
    func dailyStudiedCount(from definitions: [Definition]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var count = 0
        for definition in definitions {
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
}
