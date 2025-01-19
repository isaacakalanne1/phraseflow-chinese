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
            // Creation
            let creationDay = calendar.startOfDay(for: def.creationDate)
            creationCountsByDay[creationDay, default: 0] += 1

            // Studied
            for studyDate in def.studiedDates {
                let studyDay = calendar.startOfDay(for: studyDate)
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

        // 4) (Optional) Insert a day-before entry so the chart can start at 0
        if let earliestDay = sortedDays.first {
            if let dayBeforeEarliest = calendar.date(byAdding: .day, value: -1, to: earliestDay) {
                let zeroStats = DailyCreationAndStudyStats(
                    date: dayBeforeEarliest,
                    cumulativeCreations: 0,
                    cumulativeStudied: 0
                )
                results.insert(zeroStats, at: 0)
            }
        }

        return results
    }
}
