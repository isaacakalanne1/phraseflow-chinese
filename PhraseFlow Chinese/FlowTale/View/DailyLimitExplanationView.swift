//
//  DailyLimitExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI

struct DailyLimitExplanationView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) private var dismiss

    var title: String {
        if let limit = store.state.subscriptionState.currentSubscription?.chapterLimitPerDay {
            return LocalizedString.dailyLimitReachedWithLimit(limit)
        }
        return LocalizedString.dailyLimitReached
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(title)
                    .lineLimit(-1)
                    .font(.title)
                    .fontWeight(.semibold)

                Divider()

                Text(LocalizedString.dailyLimitWhyHeader)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(LocalizedString.dailyLimitExplanation)
                    .font(.footnote)
                    .fontWeight(.light)

                Text(LocalizedString.dailyLimitWhenCanCreateMore)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(LocalizedString.dailyLimitNextAvailable(store.state.subscriptionState.nextAvailableDescription))
                    .font(.footnote)
                    .fontWeight(.light)

                Divider()

                Text(LocalizedString.dailyLimitWhyHeader)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(LocalizedString.dailyLimitWhy)
                    .font(.footnote)
                    .fontWeight(.light)

                // TODO: Add logic to show which chapter creation dates used free trial

//                Divider()
//
//                Text("Which stories did I create today?")
//                    .font(.title2)
//                    .fontWeight(.medium)
//
//                Divider()
//
//                // Show each category’s pass/fail
//                ScrollView {
//                    if let moderationResponse = store.state.moderationResponse {
//                        ForEach(moderationResponse.categoryResults.sorted(by: { !$0.didPass && $1.didPass })) { result in
//                            HStack {
//                                if result.didPass {
//                                    Text("✅ \(result.category.name)")
//                                        .foregroundColor(.green)
//                                } else {
//                                    Text("❌ \(result.category.name)")
//                                        .foregroundColor(.red)
//                                }
//
//                                Spacer()
//
//                                // Example text:
//                                // "We accept below 80% | You scored 92%"
//                                VStack(alignment: .trailing) {
//                                    Text(LocalizedString.acceptanceThresholdExplanation("\(result.thresholdPercentageString)"))
//                                         Text(LocalizedString.userScoreExplanation("\(result.scorePercentageString)"))
//                                        .bold(!result.didPass)
//                                }
//                                .font(.footnote)
//                                .foregroundColor(.secondary)
//                            }
//                            .padding(.bottom)
//                        }
//                    }
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            PrimaryButton(title: LocalizedString.okayButton) {
                dismiss()
            }
        }
        .padding()
        .navigationTitle(LocalizedString.navigationTitleWhy)
        .navigationBarTitleDisplayMode(.inline)
        .background(FlowTaleColor.background)
    }
}
