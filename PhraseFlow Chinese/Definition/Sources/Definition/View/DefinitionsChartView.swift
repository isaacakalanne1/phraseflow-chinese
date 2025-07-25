//
//  DefinitionsChartView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import Charts
import FTColor
import SwiftUI
import Localization

// MARK: - Main View

struct DefinitionsChartView: View {
    @EnvironmentObject var store: DefinitionStore
    let definitions: [Definition]
    let isCreations: Bool

    var body: some View {
        // 1) Compute dailyCumulativeCount. You might do this in your store or here:
        // Example: let dailyCumulativeCount = makeDailyCumulativeCount(from: definitions)
        // But in your code, you said you have:
        let dailyCumulativeCount = store.state.dailyCreationAndStudyCumulative(from: definitions)

        // 2) Get the maximum cumulative count
        let maxCount = dailyCumulativeCount
            .map { isCreations ? $0.cumulativeCreations : $0.cumulativeStudied }
            .max() ?? 0

        // 3) Determine up to two "next checkpoints"
        let upcomingCheckpoints = checkpoints(for: maxCount) // see below
        // Example result: [ (400, "Intermediate"), (1000, "Advanced") ]

        // 4) Calculate the Y-axis domain max
        let yMax: Double
        if let highestCheckpoint = upcomingCheckpoints.map(\.value).max() {
            // If we have future checkpoints, show at least the highest + 10
            yMax = Double(highestCheckpoint + 10)
        } else {
            // Otherwise just scale to maxCount + 10
            yMax = Double(maxCount + 10)
        }

        // 5) Build the Chart
        return Chart {
            // -- Plot the dailyCumulativeCount data
            ForEach(dailyCumulativeCount, id: \.date) { dataPoint in
                LineMark(
                    x: .value(LocalizedString.chartDate, dataPoint.date),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords,
                              isCreations ? dataPoint.cumulativeCreations : dataPoint.cumulativeStudied)
                )
                .interpolationMethod(.linear)
                .foregroundStyle(
                    FTColor.accent
                )

                // -- Add a light fill under the line
                AreaMark(
                    x: .value(LocalizedString.chartDate, dataPoint.date),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords,
                              isCreations ? dataPoint.cumulativeCreations : dataPoint.cumulativeStudied)
                )
                .foregroundStyle(
                    FTColor.accent.opacity(0.2).gradient
                )
            }

            // Create dates for "now" and "start of day"
            let calendar = Calendar.current
            let now = Date()
            let nowComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            let nowWithCurrentHour = calendar.date(from: DateComponents(
                year: nowComponents.year,
                month: nowComponents.month,
                day: nowComponents.day,
                hour: nowComponents.hour
            )) ?? now

            // Get the start of today
            let todayStart = calendar.startOfDay(for: now)

            // Get counts for today
            let todayCreations = store.state.dailyCreationCount(from: definitions)
            let todayStudied = store.state.dailyStudiedCount(from: definitions)

            if dailyCumulativeCount.isEmpty {
                // Case 1: No historical data points - just show today's data with a point at start of day

                // Add a point at the start of the day with value 0
                LineMark(
                    x: .value(LocalizedString.chartDate, todayStart),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, 0)
                )
                .interpolationMethod(.linear)
                .foregroundStyle(FTColor.accent)

                AreaMark(
                    x: .value(LocalizedString.chartDate, todayStart),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, 0)
                )
                .foregroundStyle(FTColor.accent.opacity(0.2).gradient)

                // Add the "Now" point with today's count
                let nowValue = isCreations ? todayCreations : todayStudied

                LineMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, nowValue)
                )
                .interpolationMethod(.linear)
                .foregroundStyle(FTColor.accent)

                AreaMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, nowValue)
                )
                .foregroundStyle(FTColor.accent.opacity(0.2).gradient)

                // Symbol for the "Now" point
                PointMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, nowValue)
                )
                .symbolSize(100)
                .foregroundStyle(FTColor.accent)

            } else if let lastDataPoint = dailyCumulativeCount.last {
                // Case 2: We have historical data points plus today's data

                // Calculate cumulative values including today's data
                let nowCumulativeCreations = lastDataPoint.cumulativeCreations + (isCreations ? todayCreations : 0)
                let nowCumulativeStudied = lastDataPoint.cumulativeStudied + (!isCreations ? todayStudied : 0)
                let nowValue = isCreations ? nowCumulativeCreations : nowCumulativeStudied

                // Create a line connecting to the "Now" point
                LineMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, nowValue)
                )
                .interpolationMethod(.linear)
                .foregroundStyle(FTColor.accent)

                // Add the area fill
                AreaMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, nowValue)
                )
                .foregroundStyle(FTColor.accent.opacity(0.2).gradient)

                // Add a special point that marks "Now" with a symbol
                PointMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value(isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords, nowValue)
                )
                .symbolSize(100) // Make it visible
                .foregroundStyle(FTColor.accent)
            }

            // -- Draw each upcoming checkpoint with a dashed line
            ForEach(upcomingCheckpoints, id: \.value) { checkpoint in
                RuleMark(
                    y: .value(LocalizedString.chartCheckpoint, checkpoint.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5])) // dotted line
                .foregroundStyle(FTColor.secondary)
                .annotation(position: .top, alignment: .leading) {
                    Text(checkpoint.label)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartYScale(domain: 0 ... yMax)
        // -- Set the X-axis domain to include extra space at the right
        .chartXScale(domain: {
            let calendar = Calendar.current
            let now = Date()
            let todayStart = calendar.startOfDay(for: now)

            // Start date options:
            // 1. If we have historical data points, use the first date
            // 2. If no historical data but we have the "Now" point only, use start of today
            // 3. Default fallback to today's date
            let startDate: Date
            if let firstDate = dailyCumulativeCount.first?.date {
                // Use the first historical data point
                startDate = firstDate
            } else {
                // For the single "Now" point case, use start of today
                startDate = todayStart
            }

            // End with extra space to ensure "Now" label is visible
            let endDate = Date().addingTimeInterval(259_200) // Add 72 hours (3 days) for spacing

            return startDate ... endDate
        }())

        // -- Axis Labels
//        .chartXAxisLabel("Date", position: .bottom, alignment: .center)
//        .chartYAxisLabel("Learned words", position: .leading)

        // -- Format the X-axis with all date grid lines and special labels
        .chartXAxis {
            // Calendar setup
            let calendar = Calendar.current
            let now = Date()
            let nowComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)
            let nowWithCurrentHour = calendar.date(from: DateComponents(
                year: nowComponents.year,
                month: nowComponents.month,
                day: nowComponents.day,
                hour: nowComponents.hour
            )) ?? now

            // Show day numbers at appropriate intervals
            let startDate = dailyCumulativeCount.first?.date ?? now
            let daysCount = calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
            let stride = getOptimalStride(daysInRange: daysCount)

            // Show grid lines for all days
//            AxisMarks(values: .stride(by: .day)) { _ in
//                AxisGridLine()
//            }

            // Show formatted dates with ordinals and month where appropriate
            AxisMarks(values: .stride(by: .day, count: stride)) { value in
                if let date = value.as(Date.self) {
                    // Process ALL dates with the same logic including today/tomorrow

                    let month = calendar.component(.month, from: date)
                    let year = calendar.component(.year, from: date)

                    // Check if we need to show month/year
                    let prevDate = calendar.date(byAdding: .day, value: -stride, to: date)
                    let prevMonth = prevDate.map { calendar.component(.month, from: $0) } ?? 0
                    let prevYear = prevDate.map { calendar.component(.year, from: $0) } ?? 0

                    // Is this the first date on the axis?
                    let isFirstDateOnAxis = calendar.isDate(date, inSameDayAs: startDate)

                    // Check if the date range spans multiple years
                    let endYear = calendar.component(.year, from: now)
                    let startYear = calendar.component(.year, from: startDate)
                    let hasMultipleYears = startYear != endYear

                    // Show month if it's the first label, month changed, or no previous date
                    let showMonthName = isFirstDateOnAxis || month != prevMonth || prevDate == nil

                    // Only show year if multiple years exist in the range AND
                    // (it's the first label OR year changed OR no previous date)
                    let showYear = hasMultipleYears && (isFirstDateOnAxis || year != prevYear || prevDate == nil)

                    AxisValueLabel {
                        if showYear {
                            // Show full date with year: "2nd Feb 2024"
                            Text("\(date, format: .dateTime.day()) \(date, format: .dateTime.month(.abbreviated)) \(year)")
                                .font(FTFont.flowTaleSecondaryHeader())
                                .foregroundColor(.secondary)
                        } else if showMonthName {
                            // Show date with month: "2nd Feb"
                            Text("\(date, format: .dateTime.day()) \(date, format: .dateTime.month(.abbreviated))")
                                .font(FTFont.flowTaleSecondaryHeader())
                                .foregroundColor(.secondary)
                        } else {
                            // Just show day: "2nd"
                            Text("\(date, format: .dateTime.day())")
                                .font(FTFont.flowTaleSecondaryHeader())
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // Show the "Now" marker at current hour with left alignment
            AxisMarks(values: [nowWithCurrentHour]) { _ in
                AxisValueLabel(anchor: .leading, horizontalSpacing: 0) {
                    Text(LocalizedString.now)
                        .font(FTFont.flowTaleSecondaryHeader())
                        .fontWeight(.bold)
                        .foregroundColor(FTColor.accent)
                        .fixedSize()
                        .padding(.trailing, 10) // Add padding to shift left
                }
            }
        }

        // -- Format the Y-axis
        .chartYAxis {
            AxisMarks(position: .leading)
        }

        .padding()
    }

    // MARK: - Helper Methods

    /// Returns the optimal day stride based on the number of days in the date range
    private func getOptimalStride(daysInRange: Int) -> Int {
        switch daysInRange {
        case 0 ... 7:
            return 1 // Daily: 1, 2, 3, 4...
        case 8 ... 14:
            return 2 // Every 2 days: 2, 4, 6...
        case 15 ... 30:
            return 3 // Every 3 days: 3, 6, 9...
        case 31 ... 90:
            return 7 // Weekly: 7, 14, 21...
        case 91 ... 365:
            return 30 // Monthly: 30, 60, 90...
        default:
            return 180 // Every 6 months for very long ranges
        }
    }

    // MARK: - Next Two Checkpoints Logic

    /// Returns up to two upcoming checkpoints based on the user's current maxCount.
    ///
    /// - If maxCount < 400 => returns [ (400, "Intermediate"), (1000, "Advanced") ]
    /// - If 400 <= maxCount < 1000 => returns [ (1000, "Advanced"), (2000, "Expert") ]
    /// - If 1000 <= maxCount < 2000 => returns [ (2000, "Expert") ]
    /// - If maxCount >= 2000 => returns []
    private func checkpoints(for maxCount: Int) -> [(value: Int, label: String)] {
        let allCheckpoints = [
            (value: 400, label: "Intermediate"),
            (value: 1000, label: "Advanced"),
            (value: 2000, label: "Expert"),
        ]

        // Find the first checkpoint that is strictly above the user's max
        guard let firstIndex = allCheckpoints.firstIndex(where: { $0.value > maxCount }) else {
            // If none are above maxCount, return empty
            return []
        }

        // Return that checkpoint plus the next one (if it exists)
        var result: [(Int, String)] = []
        result.append(allCheckpoints[firstIndex])

        let nextIndex = firstIndex + 1
        if allCheckpoints.indices.contains(nextIndex) {
            result.append(allCheckpoints[nextIndex])
        }

        return result
    }
}
