//
//  FreeLimitExplanationView.swift
//  FlowTale
//
//  Created by iakalann on 19/01/2025.
//

import SwiftUI

struct FreeLimitExplanationView: View {
    @EnvironmentObject var store: FlowTaleStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                if store.state.subscriptionState.hasReachedFreeTrialLimit {
                    Text(LocalizedString.freeTrialWhatHappened)
                        .font(.title2)
                        .fontWeight(.medium)
                    Text(LocalizedString.freeTrialReachedLimit)
                        .font(.body)
                        .fontWeight(.light)
                    Divider()
                }

                Text(LocalizedString.freeTrialWhyHeader)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(LocalizedString.freeTrialExplanation)
                    .font(.body)
                    .fontWeight(.light)

                Divider()

                // TODO: Add logic to show which chapter creation dates used free trial

//                Text("Which chapters used up my free trial limit?")
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
