//
//  DefinitionsChartView.swift
//  FlowTale
//
//  Created by iakalann on 28/12/2024.
//

import SwiftUI
import Charts

// MARK: - Main View
struct DefinitionsChartView: View {
    @EnvironmentObject var store: FlowTaleStore  // Replace with your own logic
    let definitions: [Definition]
    let isCreations: Bool

    var body: some View {
        // 1) Compute dailyCumulativeCount. You might do this in your store or here:
        // Example: let dailyCumulativeCount = makeDailyCumulativeCount(from: definitions)
        // But in your code, you said you have:
        let dailyCumulativeCount = store.state.definitionState.dailyCreationAndStudyCumulative(from: definitions)

        // 2) Get the maximum cumulative count
        let maxCount = dailyCumulativeCount
            .map { isCreations ? $0.cumulativeCreations : $0.cumulativeStudied }
            .max() ?? 0

        // 3) Determine up to two "next checkpoints"
        let upcomingCheckpoints = checkpoints(for: maxCount)  // see below
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
                    y: .value((isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords),
                              (isCreations ? dataPoint.cumulativeCreations : dataPoint.cumulativeStudied))
                )
                .interpolationMethod(.linear)
                .foregroundStyle(
                    FlowTaleColor.accent
                )

                // -- Add a light fill under the line
                AreaMark(
                    x: .value(LocalizedString.chartDate, dataPoint.date),
                    y: .value((isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords),
                              (isCreations ? dataPoint.cumulativeCreations : dataPoint.cumulativeStudied))
                )
                .foregroundStyle(
                    FlowTaleColor.accent.opacity(0.2).gradient
                )
            }
            
            // Add a final data point for "Now" to ensure we use the full chart width and include today's activity
            if let lastDataPoint = dailyCumulativeCount.last, dailyCumulativeCount.count > 0 {
                // Create a date with the actual current hour
                let calendar = Calendar.current
                let now = Date()
                let nowComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)
                let nowWithCurrentHour = calendar.date(from: DateComponents(
                    year: nowComponents.year,
                    month: nowComponents.month,
                    day: nowComponents.day,
                    hour: nowComponents.hour
                )) ?? now
                
                // Get ALL definitions for today (not just those created since midnight)
                let todayCreations = store.state.definitionState.dailyCreationCount(from: definitions)
                let todayStudied = store.state.definitionState.dailyStudiedCount(from: definitions)
                
                // For the "Now" point, show all cumulative data including today's activity
                let nowCumulativeCreations = lastDataPoint.cumulativeCreations + (isCreations ? todayCreations : 0)
                let nowCumulativeStudied = lastDataPoint.cumulativeStudied + (!isCreations ? todayStudied : 0)
                
                // Create a line connecting to the "Now" point
                LineMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value((isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords),
                             (isCreations ? nowCumulativeCreations : nowCumulativeStudied))
                )
                .interpolationMethod(.linear)
                .foregroundStyle(
                    FlowTaleColor.accent
                )
                
                // Add the area fill
                AreaMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value((isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords),
                             (isCreations ? nowCumulativeCreations : nowCumulativeStudied))
                )
                .foregroundStyle(
                    FlowTaleColor.accent.opacity(0.2).gradient
                )
                
                // Add a special point that marks "Now" with a symbol
                PointMark(
                    x: .value(LocalizedString.chartDate, nowWithCurrentHour),
                    y: .value((isCreations ? LocalizedString.chartSavedDefinitions : LocalizedString.chartStudiedWords),
                             (isCreations ? nowCumulativeCreations : nowCumulativeStudied))
                )
                .symbolSize(100) // Make it visible
                .foregroundStyle(FlowTaleColor.accent)
            }

            // -- Draw each upcoming checkpoint with a dashed line
            ForEach(upcomingCheckpoints, id: \.value) { checkpoint in
                RuleMark(
                    y: .value(LocalizedString.chartCheckpoint, checkpoint.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5])) // dotted line
                .foregroundStyle(FlowTaleColor.secondary)
                .annotation(position: .top, alignment: .leading) {
                    Text(checkpoint.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartYScale(domain: 0...yMax)
        
        // -- Set the X-axis domain to include extra space at the right
        .chartXScale(domain: 
            // Start at the first date (or today if no data)
            (dailyCumulativeCount.first?.date ?? Date())
            ...
            // End with extra space (now + 2 days) to ensure "Now" label is visible and provides space for "next day data"
            Date().addingTimeInterval(259200) // Add 72 hours (3 days) for spacing
        )

        // -- Axis Labels
//        .chartXAxisLabel("Date", position: .bottom, alignment: .center)
//        .chartYAxisLabel("Learned words", position: .leading)

        // -- Format the X-axis with all date grid lines and special labels
        .chartXAxis {
            // Calendar setup
            let calendar = Calendar.current
            let now = Date()
            let today = calendar.startOfDay(for: now)
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
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if showMonthName {
                                // Show date with month: "2nd Feb" 
                                Text("\(date, format: .dateTime.day()) \(date, format: .dateTime.month(.abbreviated))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                // Just show day: "2nd"
                                Text("\(date, format: .dateTime.day())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                }
            }
            
            // Show the "Now" marker at current hour with left alignment
            AxisMarks(values: [nowWithCurrentHour]) { _ in
                AxisValueLabel(anchor: .leading, horizontalSpacing: 0) {
                    Text(LocalizedString.now)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(FlowTaleColor.accent)
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
        case 0...7:
            return 1        // Daily: 1, 2, 3, 4...
        case 8...14:
            return 2        // Every 2 days: 2, 4, 6...
        case 15...30:
            return 3        // Every 3 days: 3, 6, 9...
        case 31...90:
            return 7        // Weekly: 7, 14, 21...
        case 91...365:
            return 30       // Monthly: 30, 60, 90...
        default:
            return 180      // Every 6 months for very long ranges
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
            (value: 400,  label: "Intermediate"),
            (value: 1000, label: "Advanced"),
            (value: 2000, label: "Expert")
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
